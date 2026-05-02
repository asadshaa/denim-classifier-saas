import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Link, useNavigate } from 'react-router-dom';
import { ArrowRight, Box, Zap, Search, ShieldCheck, Cpu, Sparkles, Smartphone, Download, GitBranch, BarChart2, Loader2, Radio } from 'lucide-react';
import InteractiveDots from '../components/InteractiveDots';
import logoImage from '../logo/us-denim-logo.png';

// Import Mobile App Assets
import screen1 from '../assets/mobile/screen1.jpeg';
import screen2 from '../assets/mobile/screen2.jpeg';
import screen3 from '../assets/mobile/screen3.jpeg';
import screen4 from '../assets/mobile/screen4.jpeg';

const Landing = () => {
  const navigate = useNavigate();

  return (
    <div className="relative min-h-screen bg-background overflow-hidden selection:bg-primary/30">
      <InteractiveDots />
      {/* Dynamic Background Mesh */}
      <div className="absolute top-0 left-0 w-full h-full pointer-events-none overflow-hidden">
        <div className="absolute -top-[10%] -left-[10%] w-[40%] h-[40%] bg-primary/10 blur-[120px] rounded-full animate-pulse" />
        <div className="absolute top-[20%] -right-[10%] w-[35%] h-[35%] bg-secondary/10 blur-[100px] rounded-full" />
        <div className="absolute -bottom-[10%] left-[20%] w-[50%] h-[50%] bg-primary/5 blur-[150px] rounded-full" />
      </div>

      {/* Grid Pattern */}
      <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 brightness-100 pointer-events-none" />
      <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff05_1px,transparent_1px),linear-gradient(to_bottom,#ffffff05_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]" />

      {/* Navigation */}
      <nav className="relative z-50 flex items-center justify-between px-8 py-10 max-w-7xl mx-auto">
        <div className="flex items-center gap-3">
          <img src={logoImage} alt="US Denim Logo" className="h-12 w-auto object-contain shrink-0 drop-shadow-sm" />
        </div>
        <div className="hidden md:flex items-center gap-10">
          {[
            { label: 'Research', href: '#features' },
            { label: 'Technology', href: '#technology' },
            { label: 'Enterprise', href: '#enterprise' },
            { label: 'Dataset', href: 'https://www.kaggle.com/datasets/mustafabadshah/us-denimmm-new/', target: '_blank' }
          ].map((item) => (
            <a
              key={item.label}
              href={item.href}
              target={item.target || '_self'}
              rel={item.target ? 'noopener noreferrer' : ''}
              className="text-sm font-bold text-muted-foreground hover:text-primary transition-colors tracking-tight"
            >
              {item.label}
            </a>
          ))}
        </div>
        <div className="flex items-center gap-4">
          <Link to="/login" className="text-sm font-bold text-foreground hover:text-primary transition-colors px-6">Sign In</Link>
          <button onClick={() => navigate('/register')} className="primary-button !py-2.5 !text-sm">Get Started</button>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="relative z-10 max-w-7xl mx-auto px-8 pt-20 pb-32">
        <div className="flex flex-col items-center text-center space-y-8 max-w-4xl mx-auto">
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }}
            className="px-5 py-2 rounded-full bg-primary/10 border border-primary/20 flex items-center gap-3"
          >
            <Sparkles className="w-4 h-4 text-primary" />
            <span className="text-xs font-black text-primary uppercase tracking-[0.2em]">Next-Gen Fabric Intelligence</span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
            className="text-6xl md:text-8xl font-black text-foreground leading-[0.95] tracking-tighter"
          >
            Analyze Denim with <br />
            <span className="gradient-text">Neural Precision.</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
            className="text-xl text-muted-foreground max-w-2xl leading-relaxed font-medium"
          >
            The world's first enterprise-grade fabric classifier. Leveraging multi-head EfficientNet-B0 architectures for industrial-scale material validation.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}
            className="flex flex-col sm:flex-row items-center gap-6 pt-6"
          >
            <button onClick={() => navigate('/register')} className="primary-button !px-10 !py-4 text-lg group">
              Start Researching
              <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </button>
            <div className="flex items-center gap-3 text-muted-foreground hover:text-primary cursor-pointer transition-colors group">
              <span className="text-sm font-bold underline underline-offset-8">Read Documentation</span>
              <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </div>
          </motion.div>
        </div>

        {/* Bento Grid Features */}
        <div id="technology" className="mt-40 grid grid-cols-1 md:grid-cols-6 gap-6">
          <div className="md:col-span-3 bento-item group bg-background border border-[#0F172A]/5">
            <div className="relative z-10">
              <Cpu className="w-12 h-12 text-primary mb-6" />
              <h3 className="text-3xl font-black text-foreground mb-4 tracking-tight">EfficientNet-B0 <br />Core Engine</h3>
              <p className="text-muted-foreground text-lg leading-relaxed font-medium">Industry-standard hierarchical classification with 98.7% validated accuracy across 21 denim taxonomies.</p>
            </div>
            <div className="absolute -bottom-10 -right-10 w-48 h-48 bg-primary/10 rounded-full blur-[60px] group-hover:scale-150 transition-transform duration-700" />
          </div>

          <div className="md:col-span-3 bento-item group bg-background border border-[#0F172A]/5">
            <div className="relative z-10">
              <Zap className="w-12 h-12 text-secondary mb-6" />
              <h3 className="text-3xl font-black text-foreground mb-4 tracking-tight">Ultra-Low <br />Latency API</h3>
              <p className="text-muted-foreground text-lg leading-relaxed font-medium">Real-time inference optimized for GPU acceleration, delivering results in under 42ms per high-res sample.</p>
            </div>
            <div className="absolute -bottom-10 -right-10 w-48 h-48 bg-secondary/10 rounded-full blur-[60px] group-hover:scale-150 transition-transform duration-700" />
          </div>

          <div id="features" className="md:col-span-2 bento-item bg-background border border-[#0F172A]/5">
            <Search className="w-10 h-10 text-primary mb-6" />
            <h4 className="text-xl font-bold text-foreground mb-2">Grad-CAM XAI</h4>
            <p className="text-muted-foreground text-sm leading-relaxed">Visual attention heatmaps to explain model decision-making logic for research audit.</p>
          </div>

          <div id="enterprise" className="md:col-span-2 bento-item bg-background border border-[#0F172A]/5">
            <ShieldCheck className="w-10 h-10 text-emerald-500 mb-6" />
            <h4 className="text-xl font-bold text-foreground mb-2">Enterprise Security</h4>
            <p className="text-muted-foreground text-sm leading-relaxed">AES-256 dataset encryption and private-cluster training for proprietary fabric signatures.</p>
          </div>

          <div className="md:col-span-2 bento-item bg-primary shadow-[0_10px_40px_-10px_rgba(33,82,115,0.4)]">
            <div className="h-full flex flex-col justify-between">
              <Box className="w-10 h-10 text-white" />
              <div>
                <h4 className="text-xl font-black text-white leading-tight">Join 200+ Industrial Partners</h4>
                <p className="text-white/80 text-xs font-bold uppercase mt-2 tracking-widest">Connect to Cluster</p>
              </div>
            </div>
          </div>
        </div>

        {/* --- NEW MOBILE SHOWCASE SECTION --- */}
        <MobileShowcase />

      </main>

      {/* Footer Decoration */}
      <div className="absolute bottom-0 left-0 w-full h-[500px] bg-gradient-to-t from-background to-transparent pointer-events-none z-0" />
    </div>
  );
};

const ChevronRight = ({ className }) => (
  <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M9 5l7 7-7 7" />
  </svg>
);

const MobileShowcase = () => {
  const [activeScreen, setActiveScreen] = useState(0);
  const [isScanning, setIsScanning] = useState(false);
  const [showResult, setShowResult] = useState(false);

  // Use screen3 as the result, and 1,2,4 as the standard flow
  const standardScreens = [screen2, screen1, screen4];

  useEffect(() => {
    if (isScanning || showResult) return;
    const interval = setInterval(() => {
      setActiveScreen((prev) => (prev + 1) % standardScreens.length);
    }, 4000);
    return () => clearInterval(interval);
  }, [isScanning, showResult, standardScreens.length]);

  const handleSimulateScan = () => {
    setIsScanning(true);
    setShowResult(false);
    setTimeout(() => {
      setIsScanning(false);
      setShowResult(true);
    }, 2500); // 2.5s fake loading
  };

  const resetSimulation = () => {
    setShowResult(false);
    setIsScanning(false);
    setActiveScreen(0);
  };

  return (
    <div className="mt-40 grid lg:grid-cols-2 gap-20 items-center">
      {/* LEFT: Phone Mockup */}
      <div className="relative flex justify-center perspective-1000">
        <div className="relative z-10 phone-frame w-[320px] h-[650px] animate-float group cursor-pointer" onClick={resetSimulation}>
          <div className="phone-notch" />

          {/* Live Inference Badge */}
          <div className="absolute top-12 left-6 z-30 bg-slate-900/80 backdrop-blur-md px-3 py-1.5 rounded-full border border-white/10 flex items-center gap-2 shadow-xl">
            <div className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
            </div>
            <span className="text-[9px] font-black uppercase tracking-widest text-white">Live Inference</span>
          </div>

          {/* Screen Content */}
          <div className="w-full h-full rounded-[2rem] overflow-hidden bg-slate-900 relative">
            <AnimatePresence mode="wait">
              {isScanning ? (
                <motion.div
                  key="scanning"
                  initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                  className="absolute inset-0 flex flex-col items-center justify-center bg-slate-900 z-20"
                >
                  <div className="relative">
                    <div className="absolute inset-0 rounded-full animate-pulse-ring bg-primary" />
                    <Loader2 className="w-12 h-12 text-primary animate-spin relative z-10" />
                  </div>
                  <p className="text-white mt-8 text-xs font-black uppercase tracking-widest">Running TFLite Model...</p>
                  <p className="text-muted-foreground text-[10px] font-bold mt-2 font-mono">latency: 184ms</p>
                </motion.div>
              ) : showResult ? (
                <motion.div
                  key="result"
                  initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0 }}
                  className="absolute inset-0 z-20"
                >
                  <img src={screen3} alt="Result Screen" className="w-full h-full object-cover" />
                </motion.div>
              ) : (
                <motion.img
                  key={activeScreen}
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  transition={{ duration: 0.4 }}
                  src={standardScreens[activeScreen]}
                  alt={`Mobile App Screen ${activeScreen + 1}`}
                  className="w-full h-full object-cover absolute inset-0"
                />
              )}
            </AnimatePresence>
          </div>
        </div>

        {/* Background Glow */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] bg-primary/20 rounded-full blur-[100px] pointer-events-none" />
      </div>

      {/* RIGHT: Technical Copy */}
      <div className="space-y-10">
        <div>
          <div className="flex items-center gap-3 text-primary mb-6">
            <Smartphone className="w-6 h-6" />
            <span className="text-xs font-black uppercase tracking-[0.3em]">Mobile Deployment</span>
          </div>
          <h2 className="text-5xl md:text-6xl font-black text-foreground leading-[1.1] tracking-tighter mb-6">
            Powered by On-Device AI.<br />
            <span className="text-muted-foreground/70">No Internet Required.</span>
          </h2>
          <p className="text-lg text-muted-foreground font-medium leading-relaxed max-w-xl mb-8">
            Built using the same multi-head model powering our web analytics dashboard. Seamlessly sync predictions across web and mobile.
          </p>
        </div>

        {/* Technical Bullets */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {[
            { icon: <Cpu className="w-5 h-5" />, title: 'TensorFlow Lite', desc: 'Runs entirely on-device' },
            { icon: <Zap className="w-5 h-5" />, title: '<200ms Latency', desc: 'Optimized C++ inference' },
            { icon: <BarChart2 className="w-5 h-5" />, title: 'Multi-Head', desc: 'Main + Subclass output' },
            { icon: <Radio className="w-5 h-5" />, title: 'Quantized INT8', desc: 'Mobile memory efficiency' }
          ].map((bullet, i) => (
            <div key={i} className="flex gap-4 p-4 rounded-2xl bg-card border border-[#0F172A]/5">
              <div className="text-primary shrink-0">{bullet.icon}</div>
              <div>
                <h5 className="font-bold text-foreground text-sm tracking-tight">{bullet.title}</h5>
                <p className="text-xs text-muted-foreground font-medium mt-1">{bullet.desc}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="pt-6 flex flex-col sm:flex-row items-center gap-4">
          <button onClick={handleSimulateScan} className="primary-button !px-8 !py-4 w-full sm:w-auto flex items-center justify-center gap-3 text-sm">
            <Sparkles className="w-4 h-4" /> Simulate Scan
          </button>
          <a href="https://github.com/asadshaa/FYP" target="_blank" rel="noopener noreferrer" className="secondary-button !px-8 !py-4 w-full sm:w-auto flex items-center justify-center gap-3 text-sm bg-background border-border hover:bg-muted/30">
            <GitBranch className="w-4 h-4" /> View Source
          </a>
        </div>
      </div>
    </div>
  );
};

export default Landing;
