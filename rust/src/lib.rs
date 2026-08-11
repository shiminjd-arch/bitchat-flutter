pub mod crypto;
pub mod noise;

use std::slice;

#[no_mangle]
pub extern "C" fn bitchat_generate_ed25519_keypair(
    secret_key_out: *mut u8,
    public_key_out: *mut u8,
) {
    let (sk, pk) = crypto::generate_ed25519_keypair();
    unsafe {
        std::ptr::copy_nonoverlapping(sk.as_ptr(), secret_key_out, 32);
        std::ptr::copy_nonoverlapping(pk.as_ptr(), public_key_out, 32);
    }
}

#[no_mangle]
pub extern "C" fn bitchat_sign_ed25519(
    message: *const u8,
    message_len: u32,
    secret_key: *const u8,
    signature_out: *mut u8,
) {
    let msg = unsafe { slice::from_raw_parts(message, message_len as usize) };
    let sk: &[u8; 32] = unsafe { &*(secret_key as *const [u8; 32]) };
    let sig = crypto::sign_ed25519(msg, sk);
    unsafe {
        std::ptr::copy_nonoverlapping(sig.as_ptr(), signature_out, 64);
    }
}

#[no_mangle]
pub extern "C" fn bitchat_verify_ed25519(
    message: *const u8,
    message_len: u32,
    signature: *const u8,
    public_key: *const u8,
) -> bool {
    let msg = unsafe { slice::from_raw_parts(message, message_len as usize) };
    let sig: &[u8; 64] = unsafe { &*(signature as *const [u8; 64]) };
    let pk: &[u8; 32] = unsafe { &*(public_key as *const [u8; 32]) };
    crypto::verify_ed25519(msg, sig, pk)
}

#[no_mangle]
pub extern "C" fn bitchat_sha256(
    data: *const u8,
    data_len: u32,
    hash_out: *mut u8,
) {
    let data = unsafe { slice::from_raw_parts(data, data_len as usize) };
    let hash = crypto::sha256(data);
    unsafe {
        std::ptr::copy_nonoverlapping(hash.as_ptr(), hash_out, 32);
    }
}

#[no_mangle]
pub extern "C" fn bitchat_random_bytes(len: u32) -> *mut u8 {
    let buf = crypto::random_bytes(len as usize);
    let ptr = buf.as_ptr() as *mut u8;
    std::mem::forget(buf);
    ptr
}

#[no_mangle]
pub extern "C" fn bitchat_free_buffer(ptr: *mut u8, len: u32, capacity: u32) {
    if !ptr.is_null() {
        unsafe {
            drop(Vec::from_raw_parts(ptr, len as usize, capacity as usize));
        }
    }
}
