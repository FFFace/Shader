# Shader - 전일우

## CartoonShader / Surface

1 Pass 쉐이더입니다
TwoTone, Outline, Specualr 총 3가지를 구현했습니다.

+ TwoTone
  ```
  void surf(Input IN, inout SurfaceOutputCuston o)
  ```
  ```
  half toneDot = dot(IN.lightDir, o.Normal) * 0.5f + 0.5f;
  ```
  * 0.5f + 0.5f 를 해줌으로써 dot의 결과값을 0 ~ 1사이로 고정해줍니다.
  ```
  half tone = ceil(toneDot * 2) / 2;
  ```
  올림으로 톤 갯수를 정해줍니다.
  
+ Outline
  ```
  _OutlineBold("Outline Bold", Range(-1,1)) = 0.1
  ```
  ```
  half outline = dot(IN.viewDir, o.Normal) * 0.5f + 0.5f;
  outline -= _OutlineBold;
  outline = ceil(outline);
  ```
  카메라 방향과 노말을 통해 아웃라인을 구현했습니다.
  
+ Specular
  ```
  float3 fSpecularColor;
  float3 fReflectVector = reflect(IN.lightDir, IN.viewDir);
  float fRDotV = saturate(dot(fReflectVector, o.Normal));
  float spec = ceil(pow(fRDotV, _Specular) * _Smoothness * _SpecularColor.rgb * smap.r -0.3);
  fSpecularColor = spec * _Smoothness * _SpecularColor.rgb * smap.a;
  ```
  > 참고 : https://darkcatgame.tistory.com/21
  
  Specualr의 경우  Cartoon느낌이 계속 죽어버려 TwoTone에서 빼려고 했으나 ceil을 통해 계단을 만들어주니 나쁘지 않아 그대로 적용시켰습니다.
  Specualr영역이 너무 과해 -0.3을 해줘 영역을 제한시켰습니다. 
  +Dissolve
  ```
  fixed4 mask = tex2D(_DissolveMap, IN.uv_DissolveMap + _Time.x);
  half dissolveWidth = ceil(mask.r - (_DissolveAmount * _DissolveWidth));
  dissolve = ceil(mask.r - _DissolveAmount);
  o.Alpha = dissolve;
  ```
  ceil로 간단하게 만든 Dissolve 효과입니다.
  _DissovleAmount가 커질수록 Dissovle 영역이 굵어집니다.
  
### 최종 출력
```
o.Albedo = ((c + fSpecularColor) * tone * outline * dissolve) + (_DissolveColor * (1 - dissolve));
dissolve = ceil(mask.r - _DissolveAmount);
o.Alpha = dissolve;   
```


  
