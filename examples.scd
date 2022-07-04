

// preparation
// run this to check if you have the feedback quark
// if not, this will install a copy from the current folder
(
var path = "classes/quarks/Feedback".resolveRelative;
if(\Fb.asClass.isNil) {
	if(Git.checkForGit) {
		Quarks.install("Feedback");
	} {
		Quarks.install(path);
	};
	thisProcess.recompile;
}
);


/*

Chaos Examples

put cursor somewhere between round brackets and hit cmd-enter to run code

*/


(
Ndef(\x, {
	var x, c, m, sig;
	a = 1.1;
	c = 2.2;
	m = 1.0;
	sig = Fb({ |x|
		(a * x + c) % m; // lincong
	});
	LeakDC.ar(sig) ! 2 * 0.1
}).play
)

// control parameters with the cursor
(
Ndef(\x, {
	var x, c, m, sig;
	a = MouseX.kr(0, 2.2);
	c = MouseY.kr(0.1, 2);
	m = 1.0;

	sig = Fb({ |x|
		(a * x + c) % m; // lincong
	});
	LeakDC.ar(sig) ! 2 * 0.1
}).play
)

// filtering of different bands
(
Ndef(\x, {
	var x, c, m, sig, filterfreq;
	a = MouseX.kr(0, 2.2);
	filterfreq = MouseY.kr(20, 20000, 1);
	c = 0.5;
	m = 1.0;

	sig = Fb({ |x|
		(a * x + c) % m; // lincong
	});
	sig = LeakDC.ar(sig);
	sig = BPF.ar(sig, filterfreq, 0.1);
	sig ! 2 * 0.5
}).play
)

// stereo minimal difference
(
Ndef(\x, {
	var x, c, m, sig, difference;
	difference = MouseY.kr(0, 0.1);
	a = MouseX.kr(0, 1.9);
	c = 0.5;
	m = 1.0;

	a = a + [0, difference]; // add a little to the right channel

	sig = Fb({ |x|
		(a * x + c) % m; // lincong
	});
	LeakDC.ar(sig) * 0.1
}).play
)

// a spread of differences
(
Ndef(\x, {
	var x, c, m, sig, difference;
	difference = MouseY.kr(0, 0.5);
	a = MouseX.kr(0, 1.9);
	c = 0.5;
	m = 1.0;

	a = a + ((0..16)/16 * difference); // an array of 16 different variants

	sig = Fb({ |x|
		(a * x + c) % m; // lincong
	});
	sig = Splay.ar(sig); // spread over the stereo range
	LeakDC.ar(sig) * 0.1
}).play
)

(
Ndef(\x, {
	var x, c, m, sig, difference;
	var n = 16;
	difference = MouseY.kr(0, 0.5);
	a = MouseX.kr(0, 1.9);
	c = 0.5;
	m = 1.0;

	a = a + ((0..n-1)/16 * difference); // an array of 16 different variants

	sig = Fb({ |x|
		(a * x + c) % m; // lincong
	});
	sig = sig.collect { |z, i|
		var filterfreq = i.linexp(0, n-1, 100, 15000);
		BPF.ar(z, filterfreq, 0.1)
	};
	sig = Splay.ar(sig); // spread over the stereo range
	LeakDC.ar(sig) * 0.8
}).play
)


// different variant

(
Ndef(\x, {
	var x, c, m, sig, b;
	b = LocalBuf(s.options.blockSize);
	a = MouseX.kr(0, 2.2);
	c = MouseY.kr(0.1, 2);
	m = 1.0;
	x = Dbufrd(b, Dseries());
	x = (a * x + c) % m; // lincong
	x = Dbufwr(x, b, Dseries(1));
	sig = Duty.ar(SampleDur.ir, 0, x);
	LeakDC.ar(sig) ! 2 * 0.1
}).play
)




(
SynthDef(\gabor, {
	var env = LFGauss.ar(\sustain.ir(0.1), \width.ir(0.1), loop: 0, doneAction: 2).range(0, 1);
	var sin = SinOsc.ar(\freq.ir(440));
	OffsetOut.ar(\out.ir, Pan2.ar(sin * env * \amp.ir(0.1), \pan.ir))
}).add;

Tdef(\x, {
	var x, b, c, m;
	x = 0;
	inf.do {
		a = -5.5;
		m = 1.0;
		c = 2.2;
		x = (a * x + c) % m; // lincong
		(instrument: \gabor, \sustain: 0.02, freq: x.linexp(0, 1, 200, 3000)).play;
		0.01.wait;
	}
}).play;
)




(

var mouseX = { |min=0, max=1| Server.default.getControlBusValue(0).linlin(0, 1, min, max) };
var mouseY = { |min=0, max=1| Server.default.getControlBusValue(1).linlin(0, 1, min, max) };
{ ReplaceOut.kr(0, [MouseX.kr, MouseY.kr]) }.play;

SynthDef(\gabor, {
	var env = LFGauss.ar(\sustain.ir(0.1), \width.ir(0.1), loop: 0, doneAction: 2).range(0, 1);
	var sin = SinOsc.ar(\freq.ir(440));
	OffsetOut.ar(\out.ir, Pan2.ar(sin * env * \amp.ir(0.1), \pan.ir))
}).add;

Tdef(\x, {
	var x, b, c, m;
	x = 0;
	inf.do {
		a = mouseX.value(0, 2);
		c = mouseY.value(0, 2);
		m = 1.0;

		x = (a * x + c) % m; // lincong
		(instrument: \gabor, \sustain: 0.02, freq: x.linexp(0, 1, 200, 3000)).play;
		0.01.wait;
	}
}).play;
)

(
SynthDef(\gabor, {
	var env = LFGauss.ar(\sustain.ir(0.1), \width.ir(0.1), loop: 0, doneAction: 2).range(0, 1);
	var sin = SinOsc.ar(\freq.ir(440));
	OffsetOut.ar(\out.ir, Pan2.ar(sin * env * \amp.ir(0.1), \pan.ir))
}).add;

Tdef(\x, {
	var x, b, c, m;
	x = 0;
	inf.do { |i|
		a = i / 1000 % 10;
		m = 1.0;
		c = 1.2;
		x = (a * x + c) % m; // lincong
		(instrument: \gabor, \sustain: 0.02, freq: x.linexp(0, 1, 200, 3000)).play;
		0.01.wait;
	}
}).play;
)










