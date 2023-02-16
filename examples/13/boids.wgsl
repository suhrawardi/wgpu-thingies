struct Input {
  [[location(0)]] a_particle_pos : vec2<f32>;
  [[location(1)]] a_particle_vel : vec2<f32>;
  [[location(2)]] a_pos : vec2<f32>;
};

struct Output {
  [[builtin(position)]] position : vec4<f32>;
  [[location(0)]] v_vel : vec2<f32>;
};

[[stage(vertex)]]
fn vs_main(input: Input) -> Output {
  var output : Output;
  var angle : f32 = -atan2(input.a_particle_vel.x, input.a_particle_vel.y);
  var pos : vec2<f32> = vec2<f32>((input.a_pos.x * cos(angle)) - (input.a_pos.y * sin(angle)),
                                 (input.a_pos.x * sin(angle)) + (input.a_pos.y * cos(angle)));
  output.position = vec4<f32>(pos + input.a_particle_pos, 0.0, 1.0);
  output.v_vel = input.a_particle_vel;
  return output;
}

[[block]] struct Uniforms {
  colorScale: f32;
};

[[binding(0), group(0)]] var<uniform> param : Uniforms;

[[stage(fragment)]]
fn fs_main([[location(0)]] v_vel: vec2<f32>) -> [[location(0)]] vec4<f32> {
  let pi : f32 = 3.1415926;
  let c : f32 = param.colorScale;
  return vec4<f32>(c + (1.0-c) * sin(2.0 * pi * v_vel.x),
                   c + (1.0-c) * sin(2.0 * pi * v_vel.y),
                   c + (1.0-c) * cos(pi * (v_vel.x - v_vel.y)),
                   1.0);
}

struct Particle {
  pos : vec2<f32>;
  vel : vec2<f32>;
};

[[block]] struct SimParams {
  deltaT : f32;
  rule1Distance : f32;
  rule2Distance : f32;
  rule3Distance : f32;
  rule1Scale : f32;
  rule2Scale : f32;
  rule3Scale : f32;
};

[[block]] struct Particles {
  particles : [[stride(16)]] array<Particle>;
};

[[binding(0), group(0)]] var<uniform> params : SimParams;
[[binding(1), group(0)]] var<storage, read> particlesA : Particles;
[[binding(2), group(0)]] var<storage, read_write> particlesB : Particles;

[[stage(compute), workgroup_size(64)]]
fn cs_main([[builtin(global_invocation_id)]] GlobalInvocationID : vec3<u32>) {
  let total = arrayLength(&particlesA.particles);
  var index : u32 = GlobalInvocationID.x;
  if (index >= total) {
    return;
  }
  var vPos : vec2<f32> = particlesA.particles[index].pos;
  var vVel : vec2<f32> = particlesA.particles[index].vel;
  var cMass : vec2<f32> = vec2<f32>(0.0, 0.0);
  var cVel : vec2<f32> = vec2<f32>(0.0, 0.0);
  var colVel : vec2<f32> = vec2<f32>(0.0, 0.0);
  var cMassCount : u32 = 0u;
  var cVelCount : u32 = 0u;
  var pos : vec2<f32>;
  var vel : vec2<f32>;

  for (var i: u32 = 0u; i < total; i = i + 1u) {
    if (i == index) {
      continue;
    }
    pos = particlesA.particles[i].pos.xy;
    vel = particlesA.particles[i].vel.xy;
    if (distance(pos, vPos) < params.rule1Distance) {
      cMass = cMass + pos;
      cMassCount = cMassCount + 1u;
    }
    if (distance(pos, vPos) < params.rule2Distance) {
      colVel = colVel - (pos - vPos);
    }
    if (distance(pos, vPos) < params.rule3Distance) {
      cVel = cVel + vel;
      cVelCount = cVelCount + 1u;
    }
  }
  if (cMassCount > 0u) {
    var temp : f32 = f32(cMassCount);
    cMass = (cMass / vec2<f32>(temp, temp)) - vPos;
  }
  if (cVelCount > 0u) {
    var temp : f32 = f32(cVelCount);
    cVel = cVel / vec2<f32>(temp, temp);
  }
  vVel = vVel + (cMass * params.rule1Scale) + (colVel * params.rule2Scale) + (cVel * params.rule3Scale);
  vVel = normalize(vVel * params.deltaT);
  vPos = vPos + (vVel * params.deltaT);
  if (vPos.x < -1.0) {
    vPos.x = 1.0;
  }
  if (vPos.x > 1.0) {
    vPos.x = -1.0;
  }
  if (vPos.y < -1.0) {
    vPos.y = 1.0;
  }
  if (vPos.y > 1.0) {
    vPos.y = -1.0;
  }
  particlesB.particles[index].pos = vPos;
  particlesB.particles[index].vel = vVel;
}

