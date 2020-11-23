/* WORKLOAD --------------------------------------------------------------------------------------------------
  Created 2020 by David Herren.                                                                                 /
  https://davidherren.ch                                                                                        /
  https://github.com/herdav/workload                                                                            /
  Licensed under the MIT License.                                                                               /
  ---------------------------------------------------------------------------------------------------------------
*/

import processing.pdf.*;

Table table;

int nD = 730; // 2 years
int nW = 104;
int n4W = nW / 4;

float[] load = new float[nD];
float[] weekload = new float[nW];
float[] fourweekload = new float[n4W];
int[] day = new int[nD];

int[] months = { 3, 34, 64, 95, 125, 156, 187, 216, 247, 277, 308, 338, 369, 400, 430, 461, 491, 522, 553, 581, 612, 642, 673, 703 };
String[] monthsname = { "August 19", "September 19", "October 19", "November 19", "December 19", "January 20", "Feruary 20", "March 20", "April 20", "May 20", "June 20", "July 20", 
  "August 20", "September 20", "October 20", "November 20", "December 20", "January 21", "Feruary 21", "March 21", "April 21", "May 21", "June 21", "July 21" };
String[] weights = { "2t", "4t", "6t", "8t", "10t", "12t", "14t", "16t", "18t", "20t"};

float b;

void setup() {
  size(4380, 500); // nD * 6
  noLoop();
  b = width/nD;

  beginRecord(PDF, "workload.pdf");
  table();
  data();
  endRecord();
}

void table() {
  table = loadTable("workload.csv");

  //println(table.getRowCount() + " total rows in table");
  //println(table.getColumnCount() + " total columns in table\n");

  for (int i = 2; i < table.getColumnCount(); i++) {
    day[i] = table.getInt(1, i);
    load[day[i]] = table.getInt(5, i);
    //println(load[i]);
  }
}

void data() {
  background(250);

  // background week light -------------------------------------------------------------
  for (int i = 0; i < nD; i = i + 14) {
    fill(230, 127);
    noStroke();
    rect(i*b, 0, b*7, height);
  }

  // raster months
  for (int i = 0; i < months.length; i++) {
    strokeWeight(1);
    stroke(180);
    line(months[i]*b, 0, months[i]*b, height);

    fill(180);
    textSize(16);
    text(monthsname[i], months[i]*b+8, 20);
  }

  // weekload --------------------------------------------------------------------------
  int n = 40;
  for (int i = 0; i < weekload.length; i++) {                       
    for (int j = 0; j < 7; j++) {
      weekload[i] = weekload[i] + load[i*7+j+1];
    }
    int t = n * 7;
    noStroke();
    if (i > 0 && (weekload[i] > weekload[i-1])) fill(0, 255, 0);
    else fill(255, 0, 0);

    rect(i*7*b, height-weekload[i]/t, 7*b, weekload[i]/t);
  }

  // dayload ---------------------------------------------------------------------------
  for (int i = 0; i < load.length; i++) {
    fill(0, 127);
    rect((day[i]-1)*b, height-load[day[i]]/n, b, load[day[i]]/n);
  }

  // raster weights --------------------------------------------------------------------
  int k = 0;
  for (int i = height; i > 0; i = i - 50) {
    strokeWeight(1);
    stroke(50);
    line(0, i, width, i);
    k++;
    fill(180);
    textSize(16);
    textAlign(RIGHT);
    if (k < 10) text(weights[k-1], width-8, height-k*50-5);
  }


  // fourweekload ---------------------------------------------------------------------
  for (int i = 0; i < fourweekload.length; i++) {
    for (int j = 0; j < 4; j++) {
      fourweekload[i] = fourweekload[i] + weekload[i*4+j];
    }

    int t = n*4*7;
    strokeWeight(8);
    stroke(255, 230);
    if (i != 0) {    
      line(i*28*b, height-fourweekload[i-1]/t, (i+1)*28*b, height-fourweekload[i]/t);
    } else {
      line(i*28*b, height, (i+1)*28*b, height-fourweekload[i]/t);
    }
  }
}
