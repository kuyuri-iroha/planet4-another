
class Planet
{
  PVector pos;
  int size = 30;
  Satellite st[];
  PVector lightDirection;
  PGraphics texture;
  PGraphics horiBlur;
  PGraphics vertBlur;
  PShader gaussianShader;
  PGraphics blur;
  PShader addShader;
  
  Planet()
  {
    pos = new PVector(width/2, height/2, 0.0);
    st = new Satellite[] {
      new Satellite(),
      new Satellite(),
      new Satellite()
    };
    st[0].ori.pos.x = 100.0;
    st[0].offset.set(0, 1, 2);
    st[1].ori.pos.y = 200.0;
    st[0].offset.set(4, 5, 2);
    st[2].ori.pos.z = 150.0;
    st[0].offset.set(0, 75, 2);
    lightDirection = new PVector();

    texture = createGraphics(width, height, P3D);
    horiBlur = createGraphics(width, height, P3D);
    vertBlur = createGraphics(width, height, P3D);
    gaussianShader = loadShader("gaussian.glsl");
    blur = createGraphics(width, height, P3D);
    addShader = loadShader("add.glsl");
  }
  
  void update(float t)
  {
    for(int i=0; i<st.length; i++)
    {
      st[i].update(t);
    }
    
    float divedT = t/2;
    lightDirection.set(1.0 + (noise(divedT)-.5), 1.0 + (noise(divedT+30)-.5), -1.0 + (noise(divedT-50)-.5));
  }
  
  void draw(PGraphics render)
  {
    texture.beginDraw();
    
    texture.clear();
    
    texture.noStroke();
    texture.pushMatrix();
    
    texture.lightFalloff(0, 0.005, 0.0);
    texture.directionalLight(255, 255, 255, lightDirection.x, lightDirection.y, lightDirection.z);
    
    texture.fill(#ffffff);
    texture.translate(pos.x, pos.y, pos.z);
    texture.sphere(size);
    
    for(int i=0; i<st.length; i++)
    {
      st[i].draw(texture);
    }
    texture.popMatrix();
    
    texture.endDraw();
    
    //Blur
    gaussianShader.set("weight", gaussianWeight);
    gaussianShader.set("tex", texture);
    gaussianShader.set("horizontal", true);
    horiBlur.beginDraw();
    horiBlur.clear();
    horiBlur.filter(gaussianShader);
    horiBlur.endDraw();
    gaussianShader.set("horizontal", false);
    vertBlur.beginDraw();
    vertBlur.clear();
    vertBlur.filter(gaussianShader);
    vertBlur.endDraw();
    
    addShader.set("origin", 0.5);
    addShader.set("add", 0.5);
    addShader.set("texOrigin", horiBlur);
    addShader.set("texAdd", vertBlur);
    blur.beginDraw();
    blur.clear();
    blur.filter(addShader);
    blur.endDraw();
    
    addShader.set("origin", 1.0);
    addShader.set("add", 1.0);
    addShader.set("texOrigin", texture);
    addShader.set("texAdd", blur);
    render.filter(addShader);
  }
}
