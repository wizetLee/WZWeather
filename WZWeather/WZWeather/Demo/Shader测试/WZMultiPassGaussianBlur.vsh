
precision highp vec2;
precision mediump float;
precision mediump int;
attribute highp vec4 inputTextureCoordinate; //纹理坐标
varying highp vec2 textureCoordinate;       // XY坐标

varying highp vec2        texOffsets[5];
varying highp int passIndex;

void main(void)    {
    float blurAmount = 10.0;//外部传值配置
    int          blurLevel = int(floor(blurAmount/6.0));
    float        blurLevelModulus = mod(blurAmount, 6.0);
    float        blurRadius = 0.0;
    
    //    first three passes are just drawing the texture- do nothing
    
    //    the next six passes do gaussion blurs on the various levels
    // 根据passIndexx 设置模糊等级
    passIndex = 3;
    vec2 rendersize = vec2(1.0, 1.0);//自定义的renderSize
    if (passIndex==3 || passIndex==5 || passIndex==7 || passIndex==9)    {
        float        pixelWidth = 1.0/rendersize.x;
        
        //    pass 3 is eighth-size (blurLevel 3)
        if (passIndex==3)    {
            if (blurLevel==3)
                blurRadius = blurLevelModulus/2.0;
            else if (blurLevel>3)
                blurRadius = 3.0;
        }
        //    pass 5 is quarter-size (blurLevel 2)
        else if (passIndex==5)    {
            if (blurLevel==2)
                blurRadius = blurLevelModulus/1.5;
            else if (blurLevel>2)
                blurRadius = 4.0;
        }
        //    pass 7 is half-size (blurLevel 1)
        else if (passIndex==7)    {
            if (blurLevel==1)
                blurRadius = blurLevelModulus;
            else if (blurLevel>1)
                blurRadius = 6.0;
        }
        //    pass 9 is normal-size (blurLevel 0)
        else if (passIndex==9)    {
            if (blurLevel==0)
                blurRadius = blurLevelModulus;
            else if (blurLevel>0)
                blurRadius = 6.0;
        }
        pixelWidth *= blurRadius;
        texOffsets[0] = textureCoordinate;
        texOffsets[1] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0]-pixelWidth, textureCoordinate[1]),0.0,1.0);
        texOffsets[2] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0]+pixelWidth, textureCoordinate[1]),0.0,1.0);
        if (passIndex==3)    {
            texOffsets[3] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0]-(2.0*pixelWidth), textureCoordinate[1]),0.0,1.0);
            texOffsets[4] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0]+(2.0*pixelWidth), textureCoordinate[1]),0.0,1.0);
        }
    }
    else if (passIndex==4 || passIndex==6 || passIndex==8 || passIndex==10)    {
        float        pixelHeight = 1.0/rendersize.y;
        //    pass 4 is eighth-size (blurLevel 3)
        if (passIndex==4)    {
            if (blurLevel==3)
                blurRadius = blurLevelModulus/2.0;
            else if (blurLevel>3)
                blurRadius = 3.0;
        }
        //    pass 6 is quarter-size (blurLevel 2)
        else if (passIndex==6)    {
            if (blurLevel==2)
                blurRadius = blurLevelModulus/1.5;
            else if (blurLevel>2)
                blurRadius = 4.0;
        }
        //    pass 8 is half-size (blurLevel 1)
        else if (passIndex==8)    {
            if (blurLevel==1)
                blurRadius = blurLevelModulus;
            else if (blurLevel>1)
                blurRadius = 6.0;
        }
        //    pass 10 is normal-size (blurLevel 0)
        else if (passIndex==10)    {
            if (blurLevel==0)
                blurRadius = blurLevelModulus;
            else if (blurLevel>0)
                blurRadius = 6.0;
        }
        pixelHeight *= blurRadius;
        texOffsets[0] = textureCoordinate;
        texOffsets[1] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0], textureCoordinate[1]-pixelHeight),0.0,1.0);
        texOffsets[2] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0], textureCoordinate[1]+pixelHeight),0.0,1.0);
        if (passIndex==4)    {
            texOffsets[3] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0], textureCoordinate[1]-(2.0*pixelHeight)),0.0,1.0);
            texOffsets[4] = (blurRadius==0.0) ? textureCoordinate : clamp(vec2(textureCoordinate[0], textureCoordinate[1]+(2.0*pixelHeight)),0.0,1.0);
        }
    }
    
}
