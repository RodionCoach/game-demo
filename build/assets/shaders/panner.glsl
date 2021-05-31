---
uniform.gradientHeight: { "type": "1f", "value": -1.0 }
uniform.gradientOffset: { "type": "1f", "value": -0.2 }
uniform.colorUp: { "type": "3f", "value": {"x": 1.0, "y": 0.0, "z": 0.0} }
uniform.colorDown: { "type": "3f", "value": {"x": 0.0, "y": 1.0, "z": 0.0} }
---

#ifdef GL_ES
precision highp float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;
uniform vec3 colorUp;
uniform vec3 colorDown;

uniform float gradientHeight;
uniform float gradientOffset;

varying vec2 fragCoord;

#define FORCE 1.5
#define INIT_SPEED 40.

float rand(vec2 co) {
  return fract(sin(dot(co.xy , vec2(12.9898, 78.233))) * 43758.5453);
}

float bubbles(vec2 uv, float size, float speed, float timeOfst, float blur, float time)
{
  vec2 ruv = uv*size  + .05;
  vec2 id = ceil(ruv) + speed;

  float t = (time + timeOfst)*speed;

  ruv.y -= t * (rand(vec2(id.x))*0.5+.5)*.1;
  vec2 guv = fract(ruv) - 0.5;

  ruv = ceil(ruv);
  float g = length(guv);

  float v = rand(ruv);
  v *= step(v, clamp(FORCE, .1, .3));

  float m = smoothstep(v,v - blur, g);

  v*=.85;
  m -= smoothstep(v,v- .1, g);

  g = length(guv - vec2(v*.35, v*.35));
  float hlSize = v*.75;
  m += smoothstep(hlSize, 0., g)*.75;

  return m;
}

void main()
{
  vec2 vUv = fragCoord.xy/resolution;
  vec2 bubbleUV = (fragCoord - resolution.xy)/resolution.y;

  vec2 uv = 1.0 - vUv;
  uv.y += gradientOffset;
  float fUV = (1.0 + pow(abs(gradientHeight), 2.0));
  float mixFactor = uv.y * fUV + gradientHeight;
  vec3 mixCol = mix( colorUp, colorDown, mixFactor);
  float m = 0.;
  float sizeFactor = resolution.y / 7.;
  for(float i=-1.0; i<=0.; i+=0.15){
    vec2 iuv = uv + vec2(cos(uv.y*10. + i*20. - time*2.0)*.01, 0.);
    iuv.y *= 1.75;
    float size = (i*.3+0.5) * sizeFactor + 1.;
    m += bubbles(iuv + vec2(i*.1, 0.), size, INIT_SPEED + i*5., i*10., .4 + i*.35 * clamp(abs(cos(sin(time * 0.75 + i*5.))), 0.5, 1.0), -time) * abs(i);
  }
  m *= 1.0 - mixFactor;
  gl_FragColor = vec4(m*.4 + mixCol, 1.0);
}
