import java.util.Date;
import java.text.SimpleDateFormat;

int COL = 32;
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<String> dates = new ArrayList<String>();

int shortest = 0;
Table works;
int count;
int[] columns;
int imgW;
boolean renderNow = false;
boolean isCompleted = false;
boolean loaded  = false;
PFont font;

PImage img; 
String d = "";

PGraphics cvs;

float scroll = 0;
float scroll_step = 0;

long loadTime = 0;

void setup()
{
  //size(1920, 1080);
  fullScreen();
  cvs = createGraphics(width, height*16);
  font = loadFont("DINCondensed-Bold-64.vlw");
  textFont(font);
  background(0);
  noStroke();
  frameRate(60); //try 30
  columns = new int[COL];
  imgW = width / COL;
  textAlign(CENTER);
  
  works = loadTable("data/allworks_sorted.csv"); //<>//
  
  //println(count+"/"+works.getRowCount());
  noLoop();
  getAllImages();
  loop();
}

void draw()
{
  if(!isCompleted){
    if(renderNow){
      count++;
      d = new SimpleDateFormat("yyyy.MM.dd").format(new Date(works.getLong(count, 1)));
      img = loadImage(works.getString(count, 0));
      if(img==null)
        return;
      img.resize(imgW, 0);
    }
    else {
      img = images.get(count);
      d = dates.get(count);
      count++;
    }
    cvs.beginDraw();
    cvs.image(img, shortest*imgW, columns[shortest]);
    cvs.endDraw();
  }
  
  background(0);
  fill(255);
  textSize(64);
  text(d, width/2, height*0.85);
  fill(255, 30);
  rect(width*0.4, height*0.85+40, width*0.2, 4);
  fill(255, 125);
  textSize(32);
  rect(width*0.4, height*0.85+40, width * 0.2 * count / works.getRowCount(), 4);
  text(count, width/2, height*0.85 + 84);
  
  image(cvs, 0, int(scroll));
  scroll -= scroll_step;
  if(isCompleted)
    return;
    
  columns[shortest] += img.height;
  
  int min = 0;
  for(int i = 0; i< COL; i++)
    if(columns[i] < columns[min])
      min = i;
  shortest = min;
  
  //println(min + scroll, height/8);
  if(columns[min] + scroll >= height * 0.5){
    scroll_step += 0.01;
  }
  else
    scroll_step -= 0.01;
  
  if (scroll_step < 0)
    scroll_step = 0;

  if(renderNow && count >= works.getRowCount() || !renderNow && count >= images.size()) {
    isCompleted = true;
    println(millis() - loadTime);
    count--;
    //noLoop();
    //save("OracleWorks.png");
  }
}

void getAllImages()
{
  for (count = 1; count < works.getRowCount(); count++)
  {
    if(renderNow)
      break;
    PImage i = loadImage(works.getString(count, 0)); //path
    if(i == null)
      continue;
    i.resize(imgW, 0);
    images.add(i);
    String d = new SimpleDateFormat("yyyy.MM.dd").format(new Date(works.getLong(count, 1)));
    dates.add(d);
    println(count+"/"+works.getRowCount());
  }
  count = 0;

  loaded = true;
  isCompleted = true;
  d = "--.--.----";
  loop();
  println(images.size()+" & " + dates.size() + " loaded");
  loadTime = millis();
  println(loadTime);
}

void keyPressed()
{
  if(key != ENTER)
    return;
  if (!loaded)
    renderNow = true;
  if (loaded && isCompleted)
    isCompleted = false;
    
  
  //println("pressed");
}