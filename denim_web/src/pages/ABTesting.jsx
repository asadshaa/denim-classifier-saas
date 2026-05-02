import React, { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FlaskConical, Upload, ArrowRightLeft, Zap, TrendingUp, AlertTriangle, CheckCircle2, Loader2 } from 'lucide-react';
import axios from 'axios';

// Simulated model versions for A/B testing
// In production these would be separate model endpoints
const MODEL_VERSIONS = [
  { id: 'v1.0', label: 'Model v1.0 — Baseline EfficientNet-B0', accuracy: 0.987, note: 'Original fine-tuned model' },
  { id: 'v1.1', label: 'Model v1.1 — Data Augmented', accuracy: 0.991, note: '+Data augmentation pipeline' },
  { id: 'v1.2', label: 'Model v1.2 — LR Scheduled', accuracy: 0.993, note: '+Cosine LR decay + warmup' },
];

const UploadZone = ({ label, model, onResult, loading, result }) => {
  const fileRef = useRef();

  const handleFile = async (file) => {
    if (!file) return;
    onResult(null, true);
    try {
      const formData = new FormData();
      formData.append('image', file);
      const config = {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'multipart/form-data',
          'X-Model-Version': model.id, // pass model version header
        }
      };
      const res = await axios.post('http://localhost:5000/api/predict', formData, config);
      onResult({ ...res.data, imagePreview: URL.createObjectURL(file) }, false);
    } catch (err) {
      console.error(err);
      onResult(null, false);
    }
  };

  return (
    <div className="flex-1 flex flex-col gap-6">
      {/* Model selector badge */}
      <div className="glass-card p-4 rounded-2xl border-border flex items-center gap-3">
        <div className="w-2 h-2 rounded-full bg-primary animate-pulse" />
        <div>
          <p className="text-xs font-black text-foreground">{model.label}</p>
          <p className="text-[10px] text-muted-foreground font-bold">{model.note}</p>
        </div>
        <span className="ml-auto text-[10px] font-black text-primary bg-primary/10 px-2 py-1 rounded-lg">
          Acc: {(model.accuracy * 100).toFixed(1)}%
        </span>
      </div>

      {/* Upload zone */}
      <div
        onClick={() => fileRef.current?.click()}
        onDragOver={(e) => e.preventDefault()}
        onDrop={(e) => { e.preventDefault(); handleFile(e.dataTransfer.files[0]); }}
        className="glass-card rounded-3xl border-2 border-dashed border-border hover:border-primary/50 transition-all cursor-pointer flex flex-col items-center justify-center p-10 gap-4 min-h-[200px]"
      >
        <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={(e) => handleFile(e.target.files[0])} />
        {loading ? (
          <>
            <Loader2 className="w-10 h-10 text-primary animate-spin" />
            <p className="text-sm font-black text-muted-foreground">Running inference...</p>
          </>
        ) : result?.imagePreview ? (
          <img src={result.imagePreview} alt="Sample" className="w-full h-48 object-cover rounded-xl" />
        ) : (
          <>
            <Upload className="w-10 h-10 text-muted-foreground/40" />
            <p className="text-sm font-black text-muted-foreground text-center">Drop image or click to upload</p>
            <p className="text-[10px] text-muted-foreground/60 font-bold">for {label}</p>
          </>
        )}
      </div>

      {/* Result panel */}
      <AnimatePresence>
        {result && (
          <motion.div
            initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
            className="glass-card p-6 rounded-3xl space-y-4"
          >
            <div className="flex justify-between items-start">
              <div>
                <p className="text-2xl font-black text-foreground tracking-tighter">{result.main_class}</p>
                <p className="text-xs font-bold text-muted-foreground">Variant V{result.subclass}</p>
              </div>
              <div className={`text-2xl font-black tracking-tighter ${result.confidence_main >= 0.8 ? 'text-primary' : 'text-amber-500'}`}>
                {(result.confidence_main * 100).toFixed(1)}%
              </div>
            </div>
            <div className="space-y-2">
              {result.top_predictions?.slice(0, 3).map((p, i) => (
                <div key={i} className="flex items-center gap-3">
                  <span className="text-[10px] font-black text-muted-foreground w-20 truncate">{p.class}</span>
                  <div className="flex-1 bg-muted rounded-full h-1.5 overflow-hidden">
                    <div className="bg-primary h-full rounded-full" style={{ width: `${(p.prob * 100).toFixed(1)}%` }} />
                  </div>
                  <span className="text-[10px] font-black text-muted-foreground w-12 text-right">{(p.prob * 100).toFixed(1)}%</span>
                </div>
              ))}
            </div>
            <div className="flex items-center gap-2 pt-2 border-t border-border/50">
              <Zap className="w-3 h-3 text-muted-foreground" />
              <span className="text-[10px] font-black text-muted-foreground">{result.inference_time_ms ?? '—'}ms • {result.model_version}</span>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

const ABTesting = () => {
  const [modelA, setModelA] = useState(MODEL_VERSIONS[0]);
  const [modelB, setModelB] = useState(MODEL_VERSIONS[2]);
  const [resultA, setResultA] = useState(null);
  const [resultB, setResultB] = useState(null);
  const [loadingA, setLoadingA] = useState(false);
  const [loadingB, setLoadingB] = useState(false);

  const handleResultA = (res, loading) => { setResultA(res); setLoadingA(loading); };
  const handleResultB = (res, loading) => { setResultB(res); setLoadingB(loading); };

  const winner = resultA && resultB
    ? resultA.confidence_main >= resultB.confidence_main ? 'A' : 'B'
    : null;

  return (
    <div className="max-w-7xl mx-auto space-y-8 animate-in font-manrope pb-20">
      <div>
        <div className="flex items-center gap-3 mb-2 text-primary">
          <FlaskConical className="w-6 h-6" />
          <span className="font-black text-xs uppercase tracking-[0.3em]">Advanced ML Evaluation</span>
        </div>
        <h1 className="text-5xl font-black text-foreground tracking-tighter">A/B Model Testing</h1>
        <p className="text-muted-foreground mt-3 font-bold">Compare inference results across model versions side-by-side. Upload the same image to both panels.</p>
      </div>

      {/* Model version selectors */}
      <div className="glass-card p-6 rounded-3xl flex flex-col md:flex-row gap-6 items-start">
        <div className="flex-1">
          <label className="block text-xs font-black text-muted-foreground uppercase tracking-widest mb-2">Model A</label>
          <select
            value={modelA.id}
            onChange={(e) => setModelA(MODEL_VERSIONS.find(m => m.id === e.target.value))}
            className="w-full bg-background border border-border rounded-xl px-4 py-3 text-sm font-bold text-foreground focus:outline-none focus:border-primary"
          >
            {MODEL_VERSIONS.map(m => <option key={m.id} value={m.id}>{m.label}</option>)}
          </select>
        </div>
        <div className="flex items-center mt-7 shrink-0">
          <div className="w-10 h-10 rounded-full bg-muted flex items-center justify-center">
            <ArrowRightLeft className="w-5 h-5 text-muted-foreground" />
          </div>
        </div>
        <div className="flex-1">
          <label className="block text-xs font-black text-muted-foreground uppercase tracking-widest mb-2">Model B</label>
          <select
            value={modelB.id}
            onChange={(e) => setModelB(MODEL_VERSIONS.find(m => m.id === e.target.value))}
            className="w-full bg-background border border-border rounded-xl px-4 py-3 text-sm font-bold text-foreground focus:outline-none focus:border-primary"
          >
            {MODEL_VERSIONS.map(m => <option key={m.id} value={m.id}>{m.label}</option>)}
          </select>
        </div>
      </div>

      {/* Split screen comparison */}
      <div className="flex flex-col lg:flex-row gap-8 items-start">
        <UploadZone label="Model A" model={modelA} onResult={handleResultA} loading={loadingA} result={resultA} />
        <div className="hidden lg:flex flex-col items-center gap-4 mt-16 shrink-0">
          <div className="w-px h-32 bg-border" />
          <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center">
            <span className="text-[10px] font-black text-muted-foreground">VS</span>
          </div>
          <div className="w-px h-32 bg-border" />
        </div>
        <UploadZone label="Model B" model={modelB} onResult={handleResultB} loading={loadingB} result={resultB} />
      </div>

      {/* Comparison summary */}
      <AnimatePresence>
        {resultA && resultB && (
          <motion.div
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
            className="glass-card p-8 rounded-3xl"
          >
            <h2 className="text-2xl font-black text-foreground tracking-tighter mb-6 flex items-center gap-3">
              <TrendingUp className="w-6 h-6 text-primary" /> Comparison Analysis
            </h2>
            <div className="grid md:grid-cols-3 gap-6">
              <div className="text-center p-6 rounded-2xl bg-muted/30 border border-border">
                <p className="text-[10px] font-black text-muted-foreground uppercase tracking-widest mb-2">Confidence Delta</p>
                <p className={`text-3xl font-black tracking-tighter ${Math.abs(resultA.confidence_main - resultB.confidence_main) > 0.05 ? 'text-amber-500' : 'text-primary'}`}>
                  {((resultA.confidence_main - resultB.confidence_main) * 100).toFixed(1)}%
                </p>
                <p className="text-xs text-muted-foreground font-bold mt-1">A minus B</p>
              </div>
              <div className="text-center p-6 rounded-2xl bg-muted/30 border border-border">
                <p className="text-[10px] font-black text-muted-foreground uppercase tracking-widest mb-2">Agreement</p>
                {resultA.main_class === resultB.main_class ? (
                  <div className="flex items-center justify-center gap-2 mt-2">
                    <CheckCircle2 className="w-8 h-8 text-emerald-500" />
                    <p className="text-lg font-black text-emerald-500">Same Class</p>
                  </div>
                ) : (
                  <div className="flex items-center justify-center gap-2 mt-2">
                    <AlertTriangle className="w-8 h-8 text-amber-500" />
                    <p className="text-lg font-black text-amber-500">Disagreement</p>
                  </div>
                )}
                <p className="text-xs text-muted-foreground font-bold mt-1">
                  {resultA.main_class} vs {resultB.main_class}
                </p>
              </div>
              <div className="text-center p-6 rounded-2xl bg-primary/10 border border-primary/20">
                <p className="text-[10px] font-black text-muted-foreground uppercase tracking-widest mb-2">Higher Confidence</p>
                <p className="text-4xl font-black text-primary tracking-tighter">Model {winner}</p>
                <p className="text-xs text-muted-foreground font-bold mt-1">
                  {winner === 'A' ? modelA.label.split('—')[0].trim() : modelB.label.split('—')[0].trim()}
                </p>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default ABTesting;
