#![allow(dead_code)]
use std::{iter, mem};
use wgpu::util::DeviceExt;
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::Window,
};
use rand::{
    distributions::{Distribution, Uniform},
    SeedableRng,
}

#[path="../common/transforms.rs"]
mod transforms;

const NUM_PARTICLES: u32 = 5000;
const PARTICLES_PER_GROUP: u32 = 64;

fn main() {
    println!(" Hello test 01 ");
    let event_loop = EventLoop::new();
    let window = Window::new(&event_loop).unwrap();
    window.set_title("Mine!");
    env_logger::init();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;
        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => {}
        }
    });
}
