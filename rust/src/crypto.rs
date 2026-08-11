use aes_gcm::aead::{Aead, KeyInit};
use aes_gcm::{Aes256Gcm, Nonce};
use ed25519_dalek::{Signature, Signer, SigningKey, Verifier, VerifyingKey};
use getrandom::getrandom;
use pbkdf2::pbkdf2_hmac;
use sha2::{Digest, Sha256};

pub fn generate_ed25519_keypair() -> ([u8; 32], [u8; 32]) {
    let mut seed = [0u8; 32];
    getrandom(&mut seed).expect("failed to generate random seed");
    let signing_key = SigningKey::from_bytes(&seed);
    let verifying_key = signing_key.verifying_key();
    (signing_key.to_bytes(), verifying_key.to_bytes())
}

pub fn sign_ed25519(message: &[u8], secret_key: &[u8; 32]) -> [u8; 64] {
    let signing_key = SigningKey::from_bytes(secret_key);
    let signature: Signature = signing_key.sign(message);
    signature.to_bytes()
}

pub fn verify_ed25519(message: &[u8], signature: &[u8; 64], public_key: &[u8; 32]) -> bool {
    let sig = match Signature::from_bytes(signature) {
        Ok(s) => s,
        Err(_) => return false,
    };
    let verifying_key = match VerifyingKey::from_bytes(public_key) {
        Ok(vk) => vk,
        Err(_) => return false,
    };
    verifying_key.verify(message, &sig).is_ok()
}

pub fn encrypt_aes256gcm(plaintext: &[u8], key: &[u8; 32]) -> ([u8; 12], Vec<u8>) {
    let cipher = Aes256Gcm::new_from_slice(key).expect("invalid key length");
    let mut nonce_bytes = [0u8; 12];
    getrandom(&mut nonce_bytes).expect("failed to generate nonce");
    let nonce = Nonce::from_slice(&nonce_bytes);
    let ciphertext = cipher
        .encrypt(nonce, plaintext)
        .expect("aes-gcm encryption failed");
    (nonce_bytes, ciphertext)
}

pub fn decrypt_aes256gcm(ciphertext: &[u8], key: &[u8; 32], nonce: &[u8; 12]) -> Vec<u8> {
    let cipher = Aes256Gcm::new_from_slice(key).expect("invalid key length");
    let nonce = Nonce::from_slice(nonce);
    cipher
        .decrypt(nonce, ciphertext)
        .expect("aes-gcm decryption failed")
}

pub fn pbkdf2_sha256(password: &str, salt: &[u8], iterations: u32) -> [u8; 32] {
    let mut key = [0u8; 32];
    pbkdf2_hmac::<Sha256>(password.as_bytes(), salt, iterations, &mut key);
    key
}

pub fn random_bytes(len: usize) -> Vec<u8> {
    let mut buf = vec![0u8; len];
    getrandom(&mut buf).expect("failed to generate random bytes");
    buf
}

pub fn sha256(data: &[u8]) -> [u8; 32] {
    let mut hasher = Sha256::new();
    hasher.update(data);
    let result = hasher.finalize();
    let mut out = [0u8; 32];
    out.copy_from_slice(&result);
    out
}
