use js_sys::{Object, Reflect, WebAssembly};
use wasm_bindgen::{JsCast, JsValue};

pub fn cool_func() {
    let descriptor = Object::new();
    Reflect::set(
        &descriptor,
        &JsValue::from_str("value"),
        &JsValue::from_str("i32"),
    )
    .unwrap();

    let global = WebAssembly::Global::new(&descriptor, &JsValue::from_f64(123.)).unwrap();
    let value = JsValue::from(global);

    assert!(value.is_instance_of::<WebAssembly::Global>());
}

#[cfg(test)]
mod tests {
    use super::cool_func;

    #[cfg(all(target_arch = "wasm32", target_os = "unknown"))]
    use wasm_bindgen_test::{wasm_bindgen_test, wasm_bindgen_test_configure};

    #[cfg(all(target_arch = "wasm32", target_os = "unknown"))]
    wasm_bindgen_test_configure!(run_in_browser);

    #[cfg_attr(all(target_arch = "wasm32", target_os = "unknown"), wasm_bindgen_test)]
    #[test]
    fn it_does_the_thing() {
        cool_func();
    }
}
