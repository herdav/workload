/*WORKLOAD ----------------------------------------------------------------------------------------------------
Created 2020 by David Herren.                                                                                 /
https://davidherren.ch                                                                                        /
https://github.com/herdav/workload                                                                            /
Licensed under the MIT License.                                                                               /
---------------------------------------------------------------------------------------------------------------
*/

import processing.pdf.*;

Table table;

int nWeeks = 161;
int nDays = nWeeks * 7 + 1;
int nMonths = 41; // data.csv

Training weekload[] = new Training[nWeeks];
float[] load = new float[nDays];
float[] movingavrgeA = new float[nWeeks];
float[] movingavrgeB = new float[nWeeks];

int[] day = new int[nDays];
float avrge;
int scl = 40;
int loadShiftY;

int nMass = 25; // algo?!
Body mass[] = new Body[nMass];
float[] ffmi = new float[nMass];
float[] ffmDelta = new float[nMass];
float[] ffmStart = new float[nMass];
float[] fBase = new float[nMass];
float[] fTop = new float[nMass];

int shiftMass = 55;

int[] months = new int[nMonths];
String[] monthsname = new String[nMonths];
String[] weights = { "2t", "4t", "6t", "8t", "10t", "12t", "14t", "16t", "18t", "20t"};
String[] ffmis = { "17.0", "18.0", "19.0", "20.0", "21.0", "22.0", "23.0", "24.0", "25.0", "26.0",};

int rstr = 4;

void setup() {	
	size(4200, 1000);
	
	loadShiftY = height / 2;
	
	noLoop();
	data();
	beginRecord(PDF, "workload.pdf");
	rasterBack();
	loads();
	//movinggaverageB();
	movinggaverageA();
	rasterFront();
	//body();
	endRecord();
}

void data() {
	table = loadTable("data.csv");
	
	for (int i = 2; i < table.getColumnCount(); i++) {
		day[i] = table.getInt(2, i);
		load[day[i]] = table.getInt(3, i); //<<<<<
	}

  for (int i = 0; i < load.length; i++) {
		println(load[i]);
	}

	for (int i = 0; i < monthsname.length; i++) monthsname[i] = table.getString(0, i + 1);
	for (int i = 0; i < months.length; i++) months[i] = table.getInt(1, i + 1);
	
	avrge = table.getInt(4, 1) / scl;
	/*
	for (int i = 0; i < nMass; i++) {
		float value = table.getFloat(5, i + 1);
		//println(value);
		if (value > 0) ffmi[i] = map(value, 16.0, 26.0, 0, 120);
		else ffmi[i] = 0;
		
		ffmDelta[i] = table.getFloat(6, i + 1);
		ffmStart[i] = table.getFloat(7, i + 1);
		fBase[i] = table.getFloat(8, i + 1);
		fTop[i] = table.getFloat(9, i + 1);
	}*/
}

void rasterBack() {
	background(250);
	for (int i = 0; i < nDays; i += 14) {
		fill(230);
		noStroke();
		rect(i * rstr, 0, rstr * 7, height);
	}
	for (int i = 0; i < months.length; i++) {
		strokeWeight(1);
		stroke(180);
		line(months[i] * rstr, 0, months[i] * rstr, height);
		fill(180);
		textSize(16);
		text(monthsname[i], months[i] * rstr + 8, 20);
	}
}

void rasterFront() {
	int k = 0;
	for (int i = height; i > 0; i -= 50) {
		strokeWeight(1);
		stroke(50);
		line(0, i, width, i);
		k++;
		fill(180);
		textSize(16);
		textAlign(RIGHT);
		if (k < 10) text(weights[k - 1], width - 8, height - k * 50 - 5 - loadShiftY);
		if (k < 10) text(ffmis[k - 1], width - 8, height - k * 50 - 5);
	}
}

void movinggaverageA() {
	int k1 = 4;
	int t1 = 40 * k1 * 7;
	for (int i = k1 - 1; i < movingavrgeA.length; i++) {
		for (int j = 0; j < k1; j++) {
			movingavrgeA[i] += weekload[i - j].loadWeek;
		}
		movingavrgeA[i] /= t1;
		strokeWeight(4);
		strokeCap(ROUND);
		if (movingavrgeA[i] > movingavrgeA[i - 1]) stroke(0, 255, 0);
		else stroke(255, 0, 0);
		
		if (movingavrgeA[i] > 0 && weekload[i].loadWeek + weekload[i + 1].loadWeek  + weekload[i + 2].loadWeek > 0 && movingavrgeA[i - 1] > 0) {
			line(i * 7 * rstr, height - movingavrgeA[i - 1] - loadShiftY,(i + 1) * 7 * rstr, height - movingavrgeA[i] - loadShiftY);
		}
	}
}

void movinggaverageB() {
	int k2 = 12;
	int t2 = 40 * k2 * 7;
	for (int i = k2 - 1; i < movingavrgeB.length; i++) {
		for (int j = 0; j < k2; j++) {
			movingavrgeB[i] += weekload[i - j].loadWeek;
		}
		movingavrgeB[i] /= t2;
		strokeWeight(4);
		strokeCap(ROUND);
		if (movingavrgeB[i] > movingavrgeB[i - 1]) stroke(255, 0, 255);
		else stroke(255, 0, 255);
		
		if (movingavrgeB[i] > 0 && weekload[i].loadWeek + weekload[i + 1].loadWeek  + weekload[i + 2].loadWeek > 0 && movingavrgeB[i - 1] > 0) {
			line(i * 7 * rstr, height - movingavrgeB[i - 1] - loadShiftY,(i + 1) * 7 * rstr, height - movingavrgeB[i] - loadShiftY);
		}
	}
}

void loads() {
	for (int i = 0; i < weekload.length; i++) {
		weekload[i] = new Training(i, loadShiftY);
		for (int j = 0; j < 7; j++) {
			weekload[i].load[j] = load[i * 7 + j + 1]; // +1?
			//weekload[i].load[j] = load[i * 7 + j]; // +1?
		}
	}
	for (int i = 0; i < weekload.length; i++) {		
		weekload[i].calculate();
		if (i > 1 - 1 && weekload[i].loadWeek > weekload[i - 1].loadWeek) {
			weekload[i].week(color(50, 160));
		} else {
			weekload[i].week(color(50, 160));
		}
		weekload[i].day();
	}
}


void body() {
	for (int i = 0; i < mass.length - 1; i++) {
		mass[i] = new Body(i + shiftMass, 0, ffmStart[i], ffmDelta[i], ffmDelta[i + 1], fBase[i], fBase[i + 1], fTop[i], fTop[i + 1], ffmi[i], ffmi[i + 1]);
	}
	
	for (int i = 0; i < mass.length - 1; i++) {
		mass[i].display();
	}
}

class Training {
	int n = 7;    // 7 days
	int s = rstr;    // size
	int f1 = scl; // scale
	int f2 = f1 * n;
	float[] load = new float[n];
	float loadWeek = 0;
	PVector pos = new PVector();
	
	Training(int xpos, int ypos) {
		pos.x = xpos * n * s;
		pos.y = ypos;
	}
	
	Training() {
	}
	
	void calculate() {
		for (int i = 0; i < n; i++) {
			loadWeek = loadWeek + load[i];
		}
	}
	
	void day() {
		for (int i = 0; i < n; i++) {
			stroke(0, 60);
			strokeWeight(s);
			strokeCap(SQUARE);
			line(pos.x + i * s + 0.5 * s, height - pos.y, pos.x + i * s + 0.5 * s, height - pos.y - load[i] / f1);
		}
	}
	
	void week(color c) {
		fill(c);
		noStroke();
		rect(pos.x, height - pos.y, s * n, - 1 * loadWeek / f2);
	}
}

class Body {
	int scaleMass = 4;
	int n = 7;
	int s = rstr;
	float ffmStart;
	float ffmDeltaA, ffmDeltaB;
	float fBaseA, fBaseB;
	float fTopA, fTopB;
	float ffmiA, ffmiB;
	PVector pos = new PVector();
	
	Body(int xpos, int ypos, float ffmStart, float ffmDeltaA, float ffmDeltaB, float fBaseA, float fBaseB, float fTopA, float fTopB, float ffmiA, float ffmiB) {
		pos.x = xpos * s * n;
		pos.y = ypos;
		this.ffmStart = ffmStart * scaleMass;
		this.ffmDeltaA = ffmDeltaA * scaleMass;
		this.ffmDeltaB = ffmDeltaB * scaleMass;
		this.fBaseA = fBaseA * scaleMass;
		this.fBaseB = fBaseB * scaleMass;
		this.fTopA = fTopA * scaleMass;
		this.fTopB = fTopB * scaleMass;
		this.ffmiA = ffmiA * scaleMass;
		this.ffmiB = ffmiB * scaleMass;
	}
	
	void display() {
		float x1, y1, x2, y2, x3, y3, x4, y4;
		
		noStroke();
		x1 = pos.x;
		y1 = height - pos.y;
		x2 = pos.x + n * s;
		y2 = y1;
		x3 = x2;
		y3 = y4 = height - (pos.y + ffmDeltaB);
		x4 = x1;
		y4 = height - (pos.y + ffmDeltaA);
		fill(68, 114, 196, 200);
		quad(x1, y1, x2, y2, x3, y3, x4, y4);
		
		x1 = pos.x;
		y1 = height - (pos.y + ffmDeltaA);
		x2 = pos.x + n * s;
		y2 = height - (pos.y + ffmDeltaB);
		x3 = x2;
		y3 = y4 = height - (pos.y + ffmDeltaB + ffmStart);
		x4 = x1;
		y4 = height - (pos.y + ffmDeltaA + ffmStart);
		fill(180, 199, 231, 200);
		quad(x1, y1, x2, y2, x3, y3, x4, y4);
		
		x1 = pos.x;
		y1 = height - (pos.y + ffmDeltaA + ffmStart);
		x2 = pos.x + n * s;
		y2 = height - (pos.y + ffmDeltaB + ffmStart);
		x3 = x2;
		y3 = y4 = height - (pos.y + ffmDeltaB + ffmStart + fBaseB);
		x4 = x1;
		y4 = height - (pos.y + ffmDeltaA + ffmStart + fBaseA);
		fill(255, 0, 0, 127);
		quad(x1, y1, x2, y2, x3, y3, x4, y4);
		
		x1 = pos.x;
		y1 = height - (pos.y + ffmDeltaA + ffmStart + fBaseA);
		x2 = pos.x + n * s;
		y2 = height - (pos.y + ffmDeltaB + ffmStart + fBaseB);
		x3 = x2;
		y3 = y4 = height - (pos.y + ffmDeltaB + ffmStart + fBaseB + fTopB);
		x4 = x1;
		y4 = height - (pos.y + ffmDeltaA + ffmStart + fBaseA + fTopA);
		fill(255, 0, 0, 200);
		quad(x1, y1, x2, y2, x3, y3, x4, y4);
		
		strokeWeight(rstr);
		strokeCap(ROUND);
		stroke(0, 0, 255);
		line(pos.x, height - (pos.y + ffmiA), pos.x + n * s, height - (pos.y + ffmiB));
		
	}
}
