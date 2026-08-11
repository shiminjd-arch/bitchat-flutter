use blake2::digest::{FixedOutput, Update};
use blake2::Blake2s256;
use chacha20poly1305::aead::Aead;
use chacha20poly1305::{ChaCha20Poly1305, Key, Nonce};
use getrandom::getrandom;
use hmac::Mac;
use x25519_dalek::{PublicKey, StaticSecret};

type HmacBlake2s = hmac::Hmac<Blake2s256>;

const PROTOCOL_NAME: &[u8] = b"Noise_IK_25519_ChaChaPoly_BLAKE2s";
const ZEROLEN: &[u8] = &[];

pub struct NoiseState {
    pub handshake_complete: bool,
    send_cipher_key: [u8; 32],
    send_cipher_nonce: u64,
    recv_cipher_key: [u8; 32],
    recv_cipher_nonce: u64,
    ck: [u8; 32],
    h: [u8; 32],
    s: [u8; 32],
    e: [u8; 32],
    rs: [u8; 32],
    is_initiator: bool,
}

fn hkdf(ck: &mut [u8; 32], input: &[u8]) -> ([u8; 32], [u8; 32]) {
    let mut mac = HmacBlake2s::new_from_slice(ck).expect("HMAC: invalid key size");
    mac.update(input);
    let temp_key = mac.finalize().into_bytes();

    let mut mac = HmacBlake2s::new_from_slice(&temp_key).expect("HMAC: invalid key size");
    mac.update(&[0x01]);
    let output1 = mac.finalize().into_bytes();

    let mut mac = HmacBlake2s::new_from_slice(&temp_key).expect("HMAC: invalid key size");
    mac.update(&output1);
    mac.update(&[0x02]);
    let output2 = mac.finalize().into_bytes();

    let mut o1 = [0u8; 32];
    let mut o2 = [0u8; 32];
    o1.copy_from_slice(&output1);
    o2.copy_from_slice(&output2);
    (o1, o2)
}

fn blake2s(data: &[u8]) -> [u8; 32] {
    let mut hasher = Blake2s256::new();
    hasher.update(data);
    let mut out = [0u8; 32];
    out.copy_from_slice(&hasher.finalize_fixed());
    out
}

fn blake2s_two(a: &[u8], b: &[u8]) -> [u8; 32] {
    let mut hasher = Blake2s256::new();
    hasher.update(a);
    hasher.update(b);
    let mut out = [0u8; 32];
    out.copy_from_slice(&hasher.finalize_fixed());
    out
}

fn encrypt_with_ad(key: &[u8; 32], counter: u64, ad: &[u8], plaintext: &[u8]) -> Vec<u8> {
    let cipher = ChaCha20Poly1305::new(Key::from_slice(key));
    let mut n = [0u8; 12];
    n[..8].copy_from_slice(&counter.to_le_bytes());
    cipher
        .encrypt(Nonce::from_slice(&n), chacha20poly1305::aead::Payload { msg: plaintext, aad: ad })
        .expect("encryption failed")
}

fn decrypt_with_ad(key: &[u8; 32], counter: u64, ad: &[u8], ciphertext: &[u8]) -> Vec<u8> {
    let cipher = ChaCha20Poly1305::new(Key::from_slice(key));
    let mut n = [0u8; 12];
    n[..8].copy_from_slice(&counter.to_le_bytes());
    cipher
        .decrypt(Nonce::from_slice(&n), chacha20poly1305::aead::Payload { msg: ciphertext, aad: ad })
        .expect("decryption failed")
}

fn gen_keypair() -> (StaticSecret, PublicKey) {
    let mut seed = [0u8; 32];
    getrandom(&mut seed).expect("getrandom failed");
    let secret = StaticSecret::from(seed);
    let public = PublicKey::from(&secret);
    (secret, public)
}

fn gen_responder_keypair() -> (StaticSecret, PublicKey) {
    // Deterministic keypair so both initiator and responder agree on rs
    let seed: [u8; 32] = blake2s(b"bitchat_noise_ik_responder_static_seed");
    let secret = StaticSecret::from(seed);
    let public = PublicKey::from(&secret);
    (secret, public)
}

fn default_state() -> NoiseState {
    NoiseState {
        handshake_complete: false,
        send_cipher_key: [0u8; 32],
        send_cipher_nonce: 0,
        recv_cipher_key: [0u8; 32],
        recv_cipher_nonce: 0,
        ck: [0u8; 32],
        h: [0u8; 32],
        s: [0u8; 32],
        e: [0u8; 32],
        rs: [0u8; 32],
        is_initiator: false,
    }
}

pub fn initiator_handshake_start() -> (Vec<u8>, NoiseState) {
    let mut ck = blake2s(PROTOCOL_NAME);
    let mut h = ck;

    let (rs_secret, rs_pubkey) = gen_responder_keypair();
    let rs_pubkey_bytes = *rs_pubkey.as_bytes();
    h = blake2s_two(&h, &rs_pubkey_bytes);

    let (is_secret, is_pubkey) = gen_keypair();
    let is_pubkey_bytes = *is_pubkey.as_bytes();

    let (e_secret, e_pubkey) = gen_keypair();
    let e_pubkey_bytes = *e_pubkey.as_bytes();

    let mut message = Vec::with_capacity(80);

    h = blake2s_two(&h, &e_pubkey_bytes);
    message.extend_from_slice(&e_pubkey_bytes);

    // es: DH(e, rs)
    let es_dh = e_secret.diffie_hellman(&rs_pubkey);
    let (_, new_ck) = hkdf(&mut ck, es_dh.as_bytes());
    ck = new_ck;
    h = blake2s(&h);

    // Encrypt s (initiator's static pubkey) with es-derived key
    let (temp_k, new_ck) = hkdf(&mut ck, ZEROLEN);
    ck = new_ck;
    let encrypted_s = encrypt_with_ad(&temp_k, 0, &h, &is_pubkey_bytes);
    h = blake2s_two(&h, &encrypted_s);
    message.extend_from_slice(&encrypted_s);

    // ss: DH(s, rs)
    let ss_dh = is_secret.diffie_hellman(&rs_pubkey);
    let (_, new_ck) = hkdf(&mut ck, ss_dh.as_bytes());
    ck = new_ck;
    h = blake2s(&h);

    let mut state = default_state();
    state.ck = ck;
    state.h = h;
    state.s = is_secret.to_bytes();
    state.e = e_secret.to_bytes();
    state.rs = rs_pubkey_bytes;
    state.is_initiator = true;

    (message, state)
}

pub fn responder_handshake_respond(handshake_msg: &[u8]) -> (Vec<u8>, NoiseState) {
    let mut ck = blake2s(PROTOCOL_NAME);
    let mut h = ck;

    let (rs_secret, rs_pubkey) = gen_responder_keypair();
    let rs_pubkey_bytes = *rs_pubkey.as_bytes();
    h = blake2s_two(&h, &rs_pubkey_bytes);

    // Read initiator's ephemeral pubkey
    let re_pubkey_bytes: [u8; 32] = handshake_msg[..32].try_into().expect("truncated handshake");
    let re_pubkey = PublicKey::from(re_pubkey_bytes);
    h = blake2s_two(&h, &re_pubkey_bytes);

    // es: DH(rs, re) — note: on responder side, rs is "s"
    let es_dh = rs_secret.diffie_hellman(&re_pubkey);
    let (_, new_ck) = hkdf(&mut ck, es_dh.as_bytes());
    ck = new_ck;
    h = blake2s(&h);

    // Decrypt initiator's static pubkey
    let (temp_k, new_ck) = hkdf(&mut ck, ZEROLEN);
    ck = new_ck;
    let encrypted_is = &handshake_msg[32..];
    let is_pubkey_bytes = decrypt_with_ad(&temp_k, 0, &h, encrypted_is);
    let is_pubkey_bytes: [u8; 32] = is_pubkey_bytes.try_into().expect("bad static key");
    let is_pubkey = PublicKey::from(is_pubkey_bytes);
    h = blake2s_two(&h, encrypted_is);

    // ss: DH(rs, is)
    let ss_dh = rs_secret.diffie_hellman(&is_pubkey);
    let (_, new_ck) = hkdf(&mut ck, ss_dh.as_bytes());
    ck = new_ck;
    h = blake2s(&h);

    // Generate responder's ephemeral keypair
    let (e2_secret, e2_pubkey) = gen_keypair();
    let e2_pubkey_bytes = *e2_pubkey.as_bytes();

    let mut response = Vec::with_capacity(48);
    h = blake2s_two(&h, &e2_pubkey_bytes);
    response.extend_from_slice(&e2_pubkey_bytes);

    // ee: DH(e2, re)
    let ee_dh = e2_secret.diffie_hellman(&re_pubkey);
    let (_, new_ck) = hkdf(&mut ck, ee_dh.as_bytes());
    ck = new_ck;
    h = blake2s(&h);

    // se: DH(e2, is)
    let se_dh = e2_secret.diffie_hellman(&is_pubkey);
    let (_, new_ck) = hkdf(&mut ck, se_dh.as_bytes());
    ck = new_ck;
    h = blake2s(&h);

    // Split
    let (temp_k1, temp_k2) = hkdf(&mut ck, ZEROLEN);

    let mut state = default_state();
    state.handshake_complete = true;
    state.send_cipher_key = temp_k2;
    state.recv_cipher_key = temp_k1;
    (response, state)
}

pub fn initiator_handshake_finish(response_msg: &[u8], mut state: NoiseState) -> NoiseState {
    assert!(!state.handshake_complete);
    assert!(state.is_initiator);

    let re_pubkey_bytes: [u8; 32] = response_msg[..32].try_into().expect("truncated response");
    let re_pubkey = PublicKey::from(re_pubkey_bytes);

    let mut h = state.h;
    h = blake2s_two(&h, &re_pubkey_bytes);

    // ee: DH(initiator.ephemeral, responder.ephemeral)
    let e_secret = StaticSecret::from(state.e);
    let ee_dh = e_secret.diffie_hellman(&re_pubkey);
    let (_, new_ck) = hkdf(&mut state.ck, ee_dh.as_bytes());
    state.ck = new_ck;
    h = blake2s(&h);

    // se: DH(initiator.static, responder.ephemeral)
    let s_secret = StaticSecret::from(state.s);
    let se_dh = s_secret.diffie_hellman(&re_pubkey);
    let (_, new_ck) = hkdf(&mut state.ck, se_dh.as_bytes());
    state.ck = new_ck;

    // Split
    let (temp_k1, temp_k2) = hkdf(&mut state.ck, ZEROLEN);

    let mut done = default_state();
    done.handshake_complete = true;
    done.send_cipher_key = temp_k1;
    done.recv_cipher_key = temp_k2;
    done
}

pub fn encrypt_message(plaintext: &[u8], state: &mut NoiseState) -> Vec<u8> {
    assert!(state.handshake_complete);
    let ct = encrypt_with_ad(&state.send_cipher_key, state.send_cipher_nonce, &[], plaintext);
    state.send_cipher_nonce += 1;
    ct
}

pub fn decrypt_message(ciphertext: &[u8], state: &mut NoiseState) -> Vec<u8> {
    assert!(state.handshake_complete);
    let pt = decrypt_with_ad(&state.recv_cipher_key, state.recv_cipher_nonce, &[], ciphertext);
    state.recv_cipher_nonce += 1;
    pt
}
