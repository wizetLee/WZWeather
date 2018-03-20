
/*{
 "CREDIT": "original implementation as v002.blur in QC by anton marini and tom butterworth, ported by zoidberg",
 "CATEGORIES": [
 "Blur"
 ],
 "INPUTS": [
 {
 "NAME": "inputImage",
 "TYPE": "image"
 },
 {
 "NAME": "blurAmount",
 "TYPE": "float",
 "MIN": 0.0,
 "MAX": 24.0,
 "DEFAULT": 24.0
 }
 ],
 "PASSES": [
 {
 "TARGET": "halfSizeBaseRender",
 "WIDTH": "floor($WIDTH/3.0)",
 "HEIGHT": "floor($HEIGHT/3.0)",
 "DESCRIPTION": 0
 },
 {
 "TARGET": "quarterSizeBaseRender",
 "WIDTH": "floor($WIDTH/6.0)",
 "HEIGHT": "floor($HEIGHT/6.0)",
 "DESCRIPTION": 1
 },
 {
 "TARGET": "eighthSizeBaseRender",
 "WIDTH": "floor($WIDTH/12.0)",
 "HEIGHT": "floor($HEIGHT/12.0)",
 "DESCRIPTION": 2
 },
 {
 "TARGET": "eighthGaussA",
 "WIDTH": "floor($WIDTH/12.0)",
 "HEIGHT": "floor($HEIGHT/12.0)",
 "DESCRIPTION": 3
 },
 {
 "TARGET": "eighthGaussB",
 "WIDTH": "floor($WIDTH/12.0)",
 "HEIGHT": "floor($HEIGHT/12.0)",
 "DESCRIPTION": 4
 },
 {
 "TARGET": "quarterGaussA",
 "WIDTH": "floor($WIDTH/6.0)",
 "HEIGHT": "floor($HEIGHT/6.0)",
 "DESCRIPTION": 5
 },
 {
 "TARGET": "quarterGaussB",
 "WIDTH": "floor($WIDTH/6.0)",
 "HEIGHT": "floor($HEIGHT/6.0)",
 "DESCRIPTION": 6
 },
 {
 "TARGET": "halfGaussA",
 "WIDTH": "floor($WIDTH/3.0)",
 "HEIGHT": "floor($HEIGHT/3.0)",
 "DESCRIPTION": 7
 },
 {
 "TARGET": "halfGaussB",
 "WIDTH": "floor($WIDTH/3.0)",
 "HEIGHT": "floor($HEIGHT/3.0)",
 "DESCRIPTION": 8
 },
 {
 "TARGET": "fullGaussA",
 "DESCRIPTION": 9
 },
 {
 "TARGET": "fullGaussB",
 "DESCRIPTION": 10
 }
 ]
 }*/


/*
 eighth
 quarter                    0    1    2    3    4    5        "blurRadius" (different resolutions have different blur radiuses based on the "blurAmount" and its derived "blurLevel")
 half                    0    1    2    3    4    5                                "blurRadius"
 normal                    0    1    2    3    4    5                                                        "blurRadius"
 0    1    2    3    4    5    5                                                                            "blurRadius"
 0                        6                        12                        18                        24    "blurAmount" (attrib)
 0                        1                        2                        3                "blurLevel" (local var)
 */

uniform sampler2D inputImageTexture;
varying highp vec2 textureCoordinate;
varying highp vec2 texOffsets[5];
varying highp int passIndex;
uniform highp float blurAmount;

void main() {
    lowp int blurLevel = int(floor(blurAmount/6.0));
    lowp float blurLevelModulus = mod(blurAmount, 6.0);
    //    first three passes are just copying the input image into the buffer at varying size
    
    if (passIndex==0)    {
        gl_FragColor = texture2D(inputImageTexture.xy, textureCoordinate);
    }
    else if (passIndex==1)    {
        gl_FragColor = texture2D(inputImageTexture.xy / 3.0, textureCoordinate);
    }
    else if (passIndex==2)    {
        gl_FragColor = texture2D(inputImageTexture.xy / 6.0, textureCoordinate);
    }
    //    start reading from the previous stage- each two passes completes a gaussian blur, then we increase the resolution & blur again...
    else if (passIndex == 3)    {
////eighthSizeBaseRender..
        lowp vec4        sample0 = texture2D(inputImageTexture.xy / 12.0, texOffsets[0]);
        lowp vec4        sample1 = texture2D(inputImageTexture.xy / 12.0, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture.xy / 12.0, texOffsets[2]);
        lowp vec4        sample3 = texture2D(inputImageTexture.xy / 12.0, texOffsets[3]);
        lowp vec4        sample4 = texture2D(inputImageTexture.xy / 12.0, texOffsets[4]);
        //gl_FragColor = vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
        gl_FragColor = vec4((sample0 + sample1 + sample2 + sample3 + sample4).rgb / (5.0), 1.0);
    }
    else if (passIndex == 4)    {
        lowp vec4        sample0 = texture2D(inputImageTexture.xy / 12.0, texOffsets[0]);
        lowp vec4        sample1 = texture2D(inputImageTexture.xy / 12.0, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture.xy / 12.0, texOffsets[2]);
        lowp vec4        sample3 = texture2D(inputImageTexture.xy / 12.0, texOffsets[3]);
        lowp vec4        sample4 = texture2D(inputImageTexture.xy / 12.0, texOffsets[4]);
        //gl_FragColor = vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
        gl_FragColor = vec4((sample0 + sample1 + sample2 + sample3 + sample4).rgb / (5.0), 1.0);
    }
    else if (passIndex == 5)    {
        lowp vec4        sample0 = texture2D(inputImageTexture.xy / 12.0, texOffsets[0]);
        lowp  vec4        sample1 = texture2D(inputImageTexture.xy / 12.0, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture.xy / 12.0, texOffsets[2]);
        gl_FragColor =  vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
    }
    else if (passIndex == 6)    {
        lowp vec4        sample0 = texture2D(inputImageTexture.xy / 6.0, texOffsets[0]);
        lowp vec4        sample1 = texture2D(inputImageTexture.xy / 6.0, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture.xy / 6.0, texOffsets[2]);
        gl_FragColor =  vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
    }
    else if (passIndex == 7)    {
        lowp vec4        sample0 = texture2D(inputImageTexture.xy / 6.0, texOffsets[0]);
        lowp vec4        sample1 = texture2D(inputImageTexture.xy / 6.0, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture.xy / 6.0, texOffsets[2]);
        gl_FragColor =  vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
    }
    else if (passIndex == 8)    {
        lowp vec4        sample0 = texture2D(inputImageTexture.xy / 3.0, texOffsets[0]);
        lowp vec4        sample1 = texture2D(inputImageTexture.xy / 3.0, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture.xy / 3.0, texOffsets[2]);
        gl_FragColor =  vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
    }
    else if (passIndex == 9)    {
        lowp vec4        sample0 = texture2D(inputImageTexture.xy / 3.0, texOffsets[0]);
        lowp vec4        sample1 = texture2D(inputImageTexture.xy / 3.0, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture.xy / 3.0, texOffsets[2]);
        gl_FragColor =  vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
    }
    else if (passIndex == 10)    {
        //    this is the last pass- calculate the blurred image as i have in previous passes, then mix it in with the full-size input image using the blur amount so i get a smooth transition into the blur at low blur levels
        lowp vec4        sample0 = texture2D(inputImageTexture , texOffsets[0]);
        lowp vec4        sample1 = texture2D(inputImageTexture, texOffsets[1]);
        lowp vec4        sample2 = texture2D(inputImageTexture, texOffsets[2]);
        lowp vec4        blurredImg =  vec4((sample0 + sample1 + sample2).rgb / (3.0), 1.0);
        if (blurLevel == 0)
            gl_FragColor = mix(texture2D(inputImageTexture,textureCoordinate), blurredImg, (blurLevelModulus/6.0));
        else
            gl_FragColor = blurredImg;
    }
    
}
