/*
General Approach:        

1.    Used the map as it corresponded with my dataset.
2.    Integrated locations table directly into the dataset based on FIPS and State codes.
      Future enhancement to be to more fully automate data acquistion.  The small size and constant nature
      of the data (historical issue) makes more complete automation unnecessary.  Data preprocessing took
      place in Orange 3.3 and was drawn from the IRS CSV and the locations TSV listed in the references column.
3.    Integrated the Table.PNG to leverage the Table Class.
4.    Completed coding to support desired requirements.

Citations:
Map File                  Ben Fry, MAP.PNG (2007)[HTML Download], http://benfry.com/writing/map/map.png
Location Data:            Ben Fry, MAP.PNG (2007)[HTML Download], http://benfry.com/writing/map/locations.tsv
Tax Data:                 US Government, SOI Tax Stats - Historic Table 2 Data Tax Year 2014, (2014)
                           [Download], https://www.irs.gov/uac/soi-tax-stats-historic-table-2
Documentation:            US Government, SOI Tax Stats - Historic Table 2 Data Tax Year 2014 Documentation Guide, (2014)
                           [Download DOCx], https://www.irs.gov/uac/soi-tax-stats-historic-table-2
Incoprorated PDE Files:   Ben Fry, MAP.PNG (2007)[HTML Download], http://benfry.com/writing/map/Table.pde

*/

// Global Declarations
PImage mapUSImage;            //Image handle for US Map
Table taxTable;               //Initial class object taxTable
int rowCount;                 //Used to track total rows in table.
int statRowCount;             //Separate tracker for rows in table. 
String cStatString;           //Used to build stat strings.
char SPACEUNICODE = '\u0020'; //Established unicode space value 
int statCount = 1;            //Statcount used to track current active statistic.


//map downloaded from http://benfry.com/writing/map/map.png
void setup ()
{
  //set up basic screen components and create taxtables.
  size(640, 400);
  mapUSImage = loadImage("frymap.png");
  taxTable = new Table("TaxStats.tsv");
  rowCount = taxTable.getRowCount();
  statRowCount = taxTable.getRowCount();
  background(255);
  cStatString = "Statistic - Current Statistic"; // Not really displayed, but I hate uninitialized values
  setScreen(); // Initializes the screen, used rather than incorporating logic and junking up the draw program.
  displayCurrentStatistic();  //Initializes the first statistic to the screen.
}

void setScreen()
/*   setScreen displays the map, with the subtitle, and source reference.
     setScreen is isolated from setup (which calls it for intial setup.
     setScreen is called when the screen contents are changed to refresh the base
     visualization. 
     I wanted this approach to the display of data, this replaces use of the Integrator.pde file.
     */
{
  // Following Code Block Displays Map
  image(mapUSImage,0,0);                  
  // Following Code Block Displays Title
  textSize(15);                 // Size appropriate to map.
  fill(0);
  textAlign(CENTER,TOP);        // Grould proximity grouping with large map.
  text("Statistics of Income Selected Data", 320, 0);  //Display Main Title (Requirement)
  // Following Code Block Displays Title on Screen Resets
  textSize(12);               //Intentionally smaller than the main title.
  fill(25,25,112);            //Navy blue is used for links, easy to see with the white background (high contrast).
  textAlign(RIGHT, BOTTOM);   //Set alignment.
  text("Source - SOI Dataset, Internal Revenue Service, 2014", 639, 399);  //Display of source to reader.
}

void keyPressed()
/*  Function intercepts key using keypress function and checks if it matches unicode for space bar.
    Increments Statcount to reflect the new statistic selected.  */
{
  if (key == '\u0020')
 {
  statCount = statCount + 1; 
  if (statCount > 3) {
      statCount = statCount - 3;  // limits statcount to values 1-3
    }
  }
}

void displayCurrentStatistic()
// This section displays the current statistic, and allows setting of scalaing and color values.  It also provides default labels for the states.
{
  //the following block and declares variables.  I tend to intialize them so I don't risk an unintialized variable (sometimes I don't).
  float localMin = taxTable.getFloat(1,statCount);
  float localMax = taxTable.getFloat(1,statCount);
  cStatString = "Statistic -" + taxTable.getString(0,statCount);
  textSize(9);
  fill(0);
  textAlign(CENTER,TOP);
  text(cStatString, 320, 18);
  float scaleMin = 10;
  float scaleMax = 30;
  float scaleValue = 0;
  float ellipseHeight = 0;

  //following section allows for indvidual scaling of variables for each Statistic

  if (statCount == 1)
  {
  scaleMin = 10;
  scaleMax = 40;
  } else if (statCount == 2) {   
  scaleMin = 10;
  scaleMax = 50;
  } else if (statCount == 3) {   
  scaleMin = 10;
  scaleMax = 50;
  }
  
  // Following section is the scaling algorithm that allows the developer to configure sizes more conveniently.
    
  for (int row = 1; row < statRowCount; row++)
  {
    if (localMin > taxTable.getFloat(row, statCount)) 
    {
      localMin = taxTable.getFloat(row, statCount);
    }
    if (localMax < taxTable.getFloat(row, statCount))
    {
      localMax = taxTable.getFloat(row, statCount);
    }
  }
  //  text ("Min = " + str(localMin) + ". Max = " + str(localMax) + ".", 320,199); - Testing code, can't quite part with it.
  for (int row = 0; row < rowCount; row++) 
  {
    float x = taxTable.getFloat(row, 7);
    float y = taxTable.getFloat(row, 8);
    
    scaleValue = (((scaleMax-scaleMin)*(taxTable.getFloat(row,statCount)-localMin)/(localMax-localMin))+scaleMin); 
    
    smooth();
    noStroke();
    
    if (statCount == 1)  //section allows customizaiton of fill and and ellipse height.
    {
    fill(102,51,0);
    ellipseHeight = scaleValue;
    } else if (statCount == 2) {   
    fill(102,51,0);
    ellipseHeight = scaleValue;
    } else if (statCount == 3) {   
    fill(0,204,0);
    ellipseHeight = scaleValue;
    }
   ellipse(x, y, scaleValue, ellipseHeight);  // Draw the circle and scale the size of the statistic to fit with the chart.  


    // Provides a US State label
    textSize(9);
    fill(0);

    if (statCount == 1)
    {
    fill(102,51,0);
    textSize(9);
    fill(255,255,255);
    } else if (statCount == 2) {   
    textSize(9);
    fill(255,255,255);
    } else if (statCount == 3) {   
    textSize(9);
    fill(0);
    }

    textAlign(CENTER,CENTER);
    text(taxTable.getString(row,0), x, y);     
  }
}

void draw()
//resets the screen and displays the current statistic.
{
  if (key == '\u0020') 
  {
   setScreen();
   displayCurrentStatistic();
  }  
}