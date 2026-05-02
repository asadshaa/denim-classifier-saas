import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Link, useNavigate } from 'react-router-dom';
import { useScanStore } from '../store/scanStore';
import { useSettingsStore } from '../store/useSettingsStore';
import { 
  ArrowLeft, 
  CheckCircle2, 
  XCircle,
  Activity, 
  Target, 
  Loader2, 
  Zap, 
  Info,
  ExternalLink,
  Sparkles,
  AlertTriangle,
  ThumbsUp,
  ThumbsDown
} from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, Tooltip as RechartsTooltip, ResponsiveContainer, Cell, CartesianGrid } from 'recharts';
import axios from 'axios';

const Result = () => {
  const navigate = useNavigate();
  const { currentScan, clearCurrentScan } = useScanStore();
  const { enableHeatmap, showTopK, topKValue, confidenceThreshold, predictionMode } = useSettingsStore();
  
  const [showHeatmap, setShowHeatmap] = useState(false);
  const [heatmapUrl, setHeatmapUrl] = useState(null);
  const [heatmapLoading, setHeatmapLoading] = useState(false);
  const [feedback, setFeedback] = useState(currentScan?.feedback || null);
  const [feedbackLoading, setFeedbackLoading] = useState(false);

  const handleFeedback = async (value) => {
    if (feedback === value || feedbackLoading) return;
    setFeedbackLoading(true);
    try {
      const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
      await axios.post(`http://localhost:5000/api/predict/feedback/${currentScan._id}`, { feedback: value }, config);
      setFeedback(value);
    } catch (err) {
      console.error('Feedback failed:', err);
    } finally {
      setFeedbackLoading(false);
    }
  };

  useEffect(() => {
    if (!currentScan) {
      navigate('/dashboard');
    }
  }, [currentScan, navigate]);

  if (!currentScan) return null;

  const thresholdDecimal = confidenceThreshold / 100;
  const isLowConfidence = currentScan.confidence_main < thresholdDecimal;
  const isBlocked = predictionMode === 'strict' && isLowConfidence;

  const getCertainty = (conf) => {
    if (isLowConfidence) return { label: 'Low Confidence Warning', color: 'text-amber-500', bg: 'bg-amber-50', border: 'border-amber-400' };
    if (conf >= 0.95) return { label: 'High Precision', color: 'text-primary', bg: 'bg-primary/10', border: 'border-primary/30' };
    if (conf >= 0.80) return { label: 'Moderate Confidence', color: 'text-secondary', bg: 'bg-secondary/10', border: 'border-secondary/30' };
    return { label: 'Data Anomaly', color: 'text-red-400', bg: 'bg-red-400/10', border: 'border-red-500/30' };
  };

  const certainty = getCertainty(currentScan.confidence_main);

  const isExploratory = predictionMode === 'exploratory';
  const displayTopK = isExploratory || showTopK;

  const chartData = currentScan.top_predictions
    .slice(0, displayTopK ? topKValue : 1)
    .map(p => ({
      name: p.class,
      prob: p.prob * 100
    }));

  const handleToggleHeatmap = async () => {
    if (showHeatmap) {
      setShowHeatmap(false);
      return;
    }

    setShowHeatmap(true);
    if (!heatmapUrl && !heatmapLoading) {
      setHeatmapLoading(true);
      try {
        const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
        const res = await axios.get(`http://localhost:5000/api/predict/heatmap/${currentScan._id}`, config);
        setHeatmapUrl(`http://localhost:5000${res.data.heatmapUrl}`);
      } catch (err) {
        console.error('Failed to load heatmap', err);
        setShowHeatmap(false);
      } finally {
        setHeatmapLoading(false);
      }
    }
  };

  return (
    <div className="max-w-7xl mx-auto space-y-12 animate-in font-manrope">
      {/* Top Nav */}
      <div className="flex items-center justify-between">
         <button 
           onClick={() => { clearCurrentScan(); navigate('/dashboard'); }}
           className="flex items-center gap-3 text-muted-foreground hover:text-foreground transition-colors group"
         >
            <ArrowLeft className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
            <span className="text-sm font-black uppercase tracking-widest">Workspace Overview</span>
         </button>
         <div className="flex items-center gap-4">
            {/* Active Learning Feedback */}
            <div className="flex items-center gap-2 glass-card px-4 py-2 rounded-2xl border-border">
              <span className="text-[10px] font-black text-muted-foreground uppercase tracking-widest mr-2">Verify:</span>
              <button
                onClick={() => handleFeedback('correct')}
                disabled={feedbackLoading}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${
                  feedback === 'correct'
                    ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/20'
                    : 'text-muted-foreground hover:text-emerald-500 hover:bg-emerald-500/10'
                }`}
              >
                {feedbackLoading && feedback !== 'correct' ? <Loader2 className="w-3 h-3 animate-spin" /> : <ThumbsUp className="w-3 h-3" />}
                Correct
              </button>
              <button
                onClick={() => handleFeedback('incorrect')}
                disabled={feedbackLoading}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${
                  feedback === 'incorrect'
                    ? 'bg-red-500 text-white shadow-lg shadow-red-500/20'
                    : 'text-muted-foreground hover:text-red-500 hover:bg-red-500/10'
                }`}
              >
                {feedbackLoading && feedback !== 'incorrect' ? <Loader2 className="w-3 h-3 animate-spin" /> : <ThumbsDown className="w-3 h-3" />}
                Incorrect
              </button>
            </div>
            <div className="flex items-center gap-3 text-primary text-[10px] font-black uppercase tracking-[0.25em] bg-primary/10 px-6 py-3 rounded-2xl border border-primary/20 shadow-lg shadow-primary/5">
               <CheckCircle2 className="w-4 h-4" /> Inference Verified
            </div>
         </div>
      </div>

      <div className="grid lg:grid-cols-12 gap-12">
        {/* Visual Column */}
        <div className="lg:col-span-5 space-y-8">
           <div className="glass-card rounded-[3rem] overflow-hidden p-4 relative group shadow-2xl border-white/[0.03]">
              <img 
                src={`http://localhost:5000${currentScan.imageUrl}`} 
                alt="Analyzed Fabric" 
                className="w-full h-auto object-cover rounded-[2.25rem] shadow-2xl" 
              />
              
              <AnimatePresence>
                {enableHeatmap && showHeatmap && (
                  <motion.div 
                    initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                    className="absolute inset-4 bg-slate-900/40 rounded-[2.25rem] overflow-hidden flex items-center justify-center backdrop-blur-md"
                  >
                    {heatmapLoading ? (
                      <div className="flex flex-col items-center gap-6 text-foreground">
                        <Loader2 className="w-12 h-12 animate-spin text-primary" />
                        <span className="text-xs font-black tracking-[0.3em] uppercase">Generating Grad-CAM...</span>
                      </div>
                    ) : heatmapUrl ? (
                      <div className="relative w-full h-full">
                        <img src={heatmapUrl} alt="Heatmap Overlay" className="w-full h-full object-cover mix-blend-screen opacity-90" />
                        <div className="absolute top-8 left-8 bg-slate-900/80 backdrop-blur-2xl px-4 py-2 rounded-xl text-[10px] uppercase font-black tracking-[0.25em] text-primary border border-primary/30 shadow-2xl">
                          Inference Mode: Hybrid XAI
                        </div>
                      </div>
                    ) : null}
                  </motion.div>
                )}
              </AnimatePresence>

              {enableHeatmap && (
                <button 
                  onClick={handleToggleHeatmap}
                  className={`absolute bottom-10 right-10 backdrop-blur-2xl px-6 py-4 rounded-2xl flex items-center gap-4 transition-all duration-500 border shadow-2xl active:scale-95 ${showHeatmap ? 'bg-primary border-primary/50 text-black' : 'bg-slate-900/60 hover:bg-slate-900/80 border-white/10 text-foreground'}`}
                >
                  <Target className={`w-6 h-6 ${showHeatmap ? 'animate-pulse text-black' : 'text-primary'}`} />
                  <span className="text-xs font-black uppercase tracking-[0.2em]">{showHeatmap ? 'Disable Map' : 'Neural Attention'}</span>
                </button>
              )}
           </div>

           <div className="glass-card p-10 rounded-[3rem] border-white/[0.03] bg-background/[0.01]">
              <div className="flex items-center gap-4 mb-8">
                 <Info className="w-6 h-6 text-primary" />
                 <h4 className="text-xs font-black text-foreground uppercase tracking-[0.3em]">Sample Meta</h4>
              </div>
              <div className="space-y-6">
                 <div className="flex justify-between items-center">
                    <span className="text-muted-foreground text-[10px] font-black uppercase tracking-widest">Session ID</span>
                    <span className="text-muted-foreground font-bold tracking-tight text-sm">#{currentScan._id.slice(-8).toUpperCase()}</span>
                 </div>
                 <div className="flex justify-between items-center">
                    <span className="text-muted-foreground text-[10px] font-black uppercase tracking-widest">Inference Hub</span>
                    <span className="text-primary font-black text-sm tracking-tight">EfficientNetB0_V4</span>
                 </div>
              </div>
           </div>
        </div>

        {/* Data Column */}
        <div className="lg:col-span-7 space-y-10">
           <motion.div 
             initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }}
             className={`glass-card p-12 rounded-[3.5rem] border-l-[12px] ${isBlocked ? 'border-red-500' : certainty.border} flex flex-col md:flex-row md:items-center justify-between gap-12 border-white/[0.03]`}
           >
              {isBlocked ? (
                 <div className="w-full">
                   <p className="text-[10px] font-black text-red-500 uppercase tracking-[0.4em] mb-4 flex items-center gap-2">
                      <AlertTriangle className="w-4 h-4 text-red-500" /> Strict Mode Block
                   </p>
                   <h1 className="text-4xl font-black text-foreground tracking-tighter leading-tight mb-4">Review Required:<br/>Confidence Below Threshold</h1>
                   <p className="text-sm font-bold text-muted-foreground p-4 rounded-2xl bg-red-50 border border-red-100">
                      System threshold is set to <strong className="text-red-500">{confidenceThreshold}%</strong>. 
                      This scan only achieved <strong className="text-red-500">{(currentScan.confidence_main * 100).toFixed(1)}%</strong> certainty. 
                      It has been automatically routed to the Active Learning queue for human verification.
                   </p>
                 </div>
              ) : (
                 <>
                    <div>
                      <p className={`text-[10px] font-black ${isLowConfidence ? 'text-amber-500' : 'text-muted-foreground'} uppercase tracking-[0.4em] mb-6 flex items-center gap-2`}>
                         {isLowConfidence ? <AlertTriangle className="w-3 h-3 text-amber-500" /> : <Sparkles className="w-3 h-3 text-primary" />} 
                         {isLowConfidence ? 'Low Confidence Warning' : 'Detected Architecture'}
                      </p>
                      <div className="flex items-baseline gap-6">
                        <h1 className="text-8xl font-black text-foreground tracking-tighter leading-none">{currentScan.main_class}</h1>
                        <span className="text-3xl text-foreground font-bold tracking-tighter">V{currentScan.subclass}</span>
                      </div>
                    </div>
                    <div className={`px-8 py-5 rounded-[2rem] font-black flex items-center gap-4 shadow-2xl ${certainty.bg} ${certainty.color}`}>
                      <Zap className="w-6 h-6" />
                      <span className="text-xl tracking-tighter">{(currentScan.confidence_main * 100).toFixed(1)}%</span>
                    </div>
                 </>
              )}
           </motion.div>

           <div className="grid md:grid-cols-2 gap-10">
              <div className="glass-card p-10 rounded-[3rem] border-white/[0.03]">
                 <div className="flex items-center gap-4 mb-10">
                    <Activity className="w-6 h-6 text-secondary" />
                    <h3 className="text-xl font-black text-foreground tracking-tighter">Neural Weights</h3>
                 </div>
                 <div className="h-[250px] w-full">
                    <ResponsiveContainer width="100%" height="100%">
                      <BarChart data={chartData} layout="vertical" margin={{ top: 0, right: 30, left: 0, bottom: 0 }}>
                        <XAxis type="number" hide domain={[0, 100]} />
                        <YAxis dataKey="name" type="category" stroke="#ffffff10" fontSize={10} tickLine={false} axisLine={false} width={80} />
                        <RechartsTooltip 
                          cursor={{ fill: '#ffffff03' }}
                          contentStyle={{ backgroundColor: '#101010', border: '1px solid rgba(255,255,255,0.05)', borderRadius: '16px', fontWeight: '800', color: '#fff' }}
                          itemStyle={{ color: '#fff' }}
                          labelStyle={{ color: '#80CBC4' }}
                          formatter={(value) => [value.toFixed(1) + '%', 'Probability']}
                        />
                        <Bar dataKey="prob" radius={[0, 10, 10, 0]} barSize={24}>
                          {chartData.map((entry, index) => {
                            const colors = ['#80CBC4', '#B39DDB', '#FFAB91'];
                            return <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />;
                          })}
                        </Bar>
                      </BarChart>
                    </ResponsiveContainer>
                 </div>
              </div>

              <div className="glass-card p-10 rounded-[3rem] border-white/[0.03]">
                 <h3 className="text-xl font-black text-foreground mb-10 tracking-tighter">Automated Analysis</h3>
                 <div className="space-y-8">
                    {[
                      { label: 'Surface Texture', val: currentScan.main_class },
                      { label: 'Confidence Grade', val: currentScan.confidence_main > 0.9 ? 'Industrial Tier' : 'Research Tier' },
                      { label: 'Signature Format', val: `N-SIG-V${currentScan.subclass}` }
                    ].map((insight, i) => (
                      <div key={i} className="flex flex-col gap-2">
                         <span className="text-[10px] font-black text-muted-foreground uppercase tracking-[0.25em]">{insight.label}</span>
                         <span className="text-lg font-bold text-foreground tracking-tight">{insight.val}</span>
                      </div>
                    ))}
                 </div>
                 <div className="mt-10 pt-10 border-t border-white/5">
                    <a 
                      href="https://www.kaggle.com/datasets/mustafabadshah/us-denimmm-new/" 
                      target="_blank" 
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-3 text-primary hover:text-foreground transition-all text-[10px] font-black uppercase tracking-[0.3em]"
                    >
                       Dataset Specs <ExternalLink className="w-4 h-4" />
                    </a>
                 </div>
              </div>
           </div>
        </div>
      </div>
    </div>
  );
};

export default Result;
