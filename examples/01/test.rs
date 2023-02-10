mod common;

use winit::event_loop::EventLoop;
use std::borrow::Cow;

fn main() {
    let event_loop = EventLoop::new();
    let window = winit::window::Window::new(&event_loop).unwrap();
    window.set_title("Mine!");
    env_logger::init();

    let inputs = common::Inputs {
        source: wgpu::ShaderSource::Wgsl(Cow::Borrowed(include_str!("shader.wgsl"))),
        topology: wgpu::PrimitiveTopology::TriangleList,
        strip_index_format: None
    };

    pollster::block_on(common::run(event_loop, window, inputs, 3));
}
