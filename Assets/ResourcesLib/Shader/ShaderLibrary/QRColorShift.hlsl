

sampler2D _ColorShiftTex;

//CBUFFER_START(UnityPerMaterial)
half4 _ColorShiftSrcHSV1;
half4 _ColorShiftDstHSV1;
half _Sensitivitry1;
half _Sensitivitry2;
//CBUFFER_END



// All components are in the range [0...1], including hue.
//偏白色时，返回的色相会不统一
half3 rgb2hsv(half3 c)
{
	half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
	half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));

	half d = q.x - min(q.w, q.y);
	half e = 1.0e-10;
	return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

//All components are in the range [0...1], including hue.
half3 hsv2rgb(half3 c)
{
	half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//色相替换成新色相，明度和饱和度根据插值做偏移
half4 colorShiftImpl(half4 baseCol, half4 uv)
{
	#if QR_COLOR_SHIFT
	{
		half minCol = min(baseCol.r, min(baseCol.g, baseCol.b));
		half maxCol = max(baseCol.r, max(baseCol.g, baseCol.b));
		half brightness = maxCol;
		half saturation = 1 - minCol / maxCol;

		// 不要 saturate, hsv.s 或 hsv.v 大于1时， 转换成rgb时， 信息会丢失
		half3 hsvOffset1 = _ColorShiftDstHSV1.rgb - _ColorShiftSrcHSV1.rgb;
		half3 dstHSV1 = half3(_ColorShiftSrcHSV1.r, saturation, brightness) + hsvOffset1;
		dstHSV1.r += lerp(0, 1, _Sensitivitry1);
		dstHSV1.g += lerp(0, 1, _Sensitivitry2);
		half3 dstRGB1 = hsv2rgb(dstHSV1);
		half4 colorShiftTexCol = tex2Dbias(_ColorShiftTex, uv);
		baseCol =half4(lerp(baseCol.rgb, dstRGB1, colorShiftTexCol.r), colorShiftTexCol.g);
	}
	#endif

	return baseCol;
}

half4 colorShift(half4 baseCol, half4 uv) { return colorShiftImpl(baseCol, uv); }
half4 colorShift(half4 baseCol, half2 uv) { return colorShiftImpl(baseCol, half4(uv, 0, 0)); }