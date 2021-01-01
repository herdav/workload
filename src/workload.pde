/*WORKLOAD ----------------------------------------------------------------------------------------------------
Created 2020 by David Herren.                                                                                 /
https://davidherren.ch                                                                                        /
https://github.com/herdav/workload                                                                            /
Licensed under the MIT License.                                                                               /
---------------------------------------------------------------------------------------------------------------
*/

import processing.pdf.*;

Table table;

int nDays = 730; // 2 years
int nWeeks = 104;
int n4Weeks = nWeeks / 4;
int nMonths = 24;

Weekload weekload[] = new Weekload[nWeeks];

float[] load = new float[nDays];
float[] fourweekload = new float[n4Weeks];
int[] day = new int[nDays];

float[] ffmi = new float[nWeeks];
int ffmiShift = 54;

int[] months = new int[nMonths];
String[] monthsname = new String[nMonths];
String[] weights = { "2t", "4t", "6t", "8t", "10t", "12t", "14t", "16t", "18t", "20t"};

float rstr;

void setup() {	
	size(4380, 500); // nDays * 6
	noLoop();
	data();
	beginRecord(PDF, "workload.pdf");
	raster();
	loads();
	fourweekload();
	ffmi();
	endRecord();
}

void data() {
	table = loadTable("data.csv");
	for (int i = 2; i < table.getColumnCount(); i++) {
		day[i] = table.getInt(1, i);
		load[day[i]] = table.getInt(3, i);
	}
	for (int i = 0; i < ffmi.length; i++) {
		String value = table.getString(4, i + 1);
		if (float(value) > 0) ffmi[i] = map(float(value), 18, 25, 0, 1000);
		else ffmi[i] = 0;
	}
	for (int i = 0; i < monthsname.length; i++) monthsname[i] = table.getString(5, i + 1);
	for (int i = 0; i < months.length; i++) months[i] = table.getInt(6, i + 1);
}

void raster() {
	background(250);
	rstr = width / nDays;
	for (int i = 0; i < nDays; i += 14) {
		fill(230, 127);
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
	
	int k = 0;
	for (int i = height; i > 0; i -= 50) {
		strokeWeight(1);
		stroke(50);
		line(0, i, width, i);
		k++;
		fill(180);
		textSize(16);
		textAlign(RIGHT);
		if (k < 10) text(weights[k - 1], width - 8, height - k * 50 - 5);
	}
}

void fourweekload() {
	for (int i = 0; i < fourweekload.length; i++) {
		for (int j = 0; j < 4; j++) {
			fourweekload[i] = fourweekload[i] + weekload[i * 4 + j].loadWeek;
		}
		int t = 40 * 4 * 7;
		strokeWeight(8);
		strokeCap(ROUND);
		if (i > 0 && (fourweekload[i] < fourweekload[i - 1])) stroke(255, 0, 0);
		else stroke(0, 255, 0);
		if (i != 0) line(i * 28 * rstr, height - fourweekload[i - 1] / t,(i + 1) * 28 * rstr, height - fourweekload[i] / t);
		else line(i * 28 * rstr, height,(i + 1) * 28 * rstr, height - fourweekload[i] / t);
	}
}

void ffmi() {
	for (int i = 0; i < ffmi.length - 1; i++) {
		stroke(0, 0, 255);
		strokeWeight(4);
		strokeCap(ROUND);
		if (ffmi[i] != 0 && ffmi[i + 1] != 0) line((i + ffmiShift) * 7 * rstr, height - ffmi[i],(i + 1 + ffmiShift) * 7 * rstr, height - ffmi[i + 1]);
		noStroke();
	}
}

void loads() {
	for (int i = 0; i < weekload.length; i++) {
		weekload[i] = new Weekload(i, 0);
		for (int j = 0; j < 7; j++) {
			weekload[i].load[j] = load[i * 7 + j + 1]; // +1?
		}
	}
	for (int i = 0; i < weekload.length; i++) {		
		weekload[i].calculate();
		if (i > 1 - 1 && weekload[i].loadWeek > weekload[i - 1].loadWeek) {
			weekload[i].week(color(0, 255, 0, 127));
		} else {
			weekload[i].week(color(255, 0, 0, 127));
		}
		weekload[i].day();
	}
}


class Weekload {
	int t = 7;   // 7 days
	int s = 6;   // size
	int f1 = 40; // scale
	int f2 = f1 * t;
	float[] load = new float[t];
	float loadWeek = 0;
	PVector pos = new PVector();
	
	Weekload(int xpos, int ypos) {
		pos.x = xpos * t * s;
		pos.y = ypos;
	}
	
	Weekload() {
	}
	
	void calculate() {
		for (int i = 0; i < t; i++) {
			loadWeek = loadWeek + load[i];
		}
	}
	
	void day() {
		for (int i = 0; i < t; i++) {
			stroke(127);
			strokeWeight(s);
			strokeCap(SQUARE);
			line(pos.x + i * s + 0.5 * s, height - pos.y, pos.x + i * s + 0.5 * s, height - pos.y - load[i] / f1);
		}
	}
	
	void week(color c) {
		fill(c);
		noStroke();
		rect(pos.x, height, s * t, - 1 * loadWeek / f2);
	}
}
