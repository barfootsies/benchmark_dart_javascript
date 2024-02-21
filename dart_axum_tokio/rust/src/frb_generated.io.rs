// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.24.

// Section: imports

use super::*;
use crate::api::minimal::*;
use flutter_rust_bridge::for_generated::byteorder::{NativeEndian, ReadBytesExt, WriteBytesExt};
use flutter_rust_bridge::for_generated::transform_result_dco;
use flutter_rust_bridge::{Handler, IntoIntoDart};

// Section: boilerplate

flutter_rust_bridge::frb_generated_boilerplate_io!();

#[no_mangle]
pub extern "C" fn frbgen_dart_axum_tokio_sever_rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLocksimd_jsonError(
    ptr: *const std::ffi::c_void,
) {
    MoiArc::<flutter_rust_bridge::for_generated::rust_async::RwLock<simd_json :: Error>>::increment_strong_count(ptr as _);
}

#[no_mangle]
pub extern "C" fn frbgen_dart_axum_tokio_sever_rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLocksimd_jsonError(
    ptr: *const std::ffi::c_void,
) {
    MoiArc::<flutter_rust_bridge::for_generated::rust_async::RwLock<simd_json :: Error>>::decrement_strong_count(ptr as _);
}

#[no_mangle]
pub extern "C" fn frbgen_dart_axum_tokio_sever_rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLocksimd_jsonOwnedValue(
    ptr: *const std::ffi::c_void,
) {
    MoiArc::<flutter_rust_bridge::for_generated::rust_async::RwLock<simd_json :: OwnedValue>>::increment_strong_count(ptr as _);
}

#[no_mangle]
pub extern "C" fn frbgen_dart_axum_tokio_sever_rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLocksimd_jsonOwnedValue(
    ptr: *const std::ffi::c_void,
) {
    MoiArc::<flutter_rust_bridge::for_generated::rust_async::RwLock<simd_json :: OwnedValue>>::decrement_strong_count(ptr as _);
}