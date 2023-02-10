#![allow(dead_code)]
use cgmath::{ Matrix4, Vector3, Rad};

pub fn create_transforms(translation:[f32; 3], rotation[f32; 3], scaling:[f32; 3]) -> Matrix4<f32> {
    let trans_mat = Matrix4::from_translation(Vector3::new(translation[0], translation[1], translation[2]));
    let rotate_mat_x = Matrix4::from_angle_x(Rad(rotation[0]));
    let rotate_mat_y = Matrix4::from_angle_y(Rad(rotation[1]));
    let rotate_mat_z = Matrix4::from_angle_z(Rad(rotation[2]));
    let scale_mat = Matrix4::from_nonuniform_scale(scaling[0], scaling[1], scaling[2]);

    let model_mat = trans_mat * rotate_mat_x * rotate_mat_y * rotate_mat_z * scale_mat;

    model_mat
}

pub fn create_view(camera_position: Point3<f32>, look_directrion: Point3<f32>, up_directrion: Vector3<f32>) -> Matrix4<f32> {
    Matrix4::look_at_rh(camera_position, look_direction, up_directrion)
}

pub fn create_projection(aspect:f32, is_perspective:bool) -> Matrix4<f32> {
    let project_mat:Matrix4<f32>;
    if is_perspective {
        project_mat = OPENGL_TO_WGPU_MATRIX * perspective(Rad(2.0*PI/5.0), aspect, 0.1, 100.0);
    } else {
        project_mat = OPENGL_TO_WGPU_MATRIX * ortho(-4.0, 4.0, -3.0, 3.0, -1.0, 6.0);
    }
    project_mat
}
