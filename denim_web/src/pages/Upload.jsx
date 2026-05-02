import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { Upload as UploadIcon, Image as ImageIcon, Loader2, BrainCircuit, X, Plus, Sparkles, ArrowRight, Layers } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useScanStore } from '../store/scanStore';
import { useSettingsStore } from '../store/useSettingsStore';
import API_URL from '../api';

const Upload = () => {
  const [files, setFiles] = useState([]);
  const [previews, setPreviews] = useState([]);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [progress, setProgress] = useState(0);
  const [statusText, setStatusText] = useState("");
  
  const { setCurrentScan, addScanToHistory, addFlaggedScan } = useScanStore();
  const { confidenceThreshold } = useSettingsStore();
  const navigate = useNavigate();

  const onDrop = useCallback((acceptedFiles) => {
    const newFiles = [...files, ...acceptedFiles].slice(0, 50);
    setFiles(newFiles);
    const newPreviews = newFiles.map(file => URL.createObjectURL(file));
    setPreviews(newPreviews);
  }, [files]);

  const removeFile = (index) => {
    const newFiles = [...files];
    newFiles.splice(index, 1);
    setFiles(newFiles);
    const newPreviews = [...previews];
    newPreviews.splice(index, 1);
    setPreviews(newPreviews);
  };

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': ['.jpeg', '.jpg', '.png'] },
    maxFiles: 50
  });

  const handleUpload = async () => {
    if (files.length === 0) return;
    setIsAnalyzing(true);
    setProgress(0);

    try {
      const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
      
      if (files.length === 1) {
        setStatusText("Neural Mapping...");
        const formData = new FormData();
        formData.append('image', files[0]);
        const res = await axios.post(`${API_URL}/api/predict`, formData, config);
        
        const scanData = res.data;
        setCurrentScan(scanData);
        addScanToHistory(scanData);
        
        // Check if it belongs in Active Learning
        if (scanData.confidence_main < confidenceThreshold / 100) {
          addFlaggedScan(scanData);
        }

        setIsAnalyzing(false);
        navigate('/result');
      } else {
        setStatusText("Batch Pipeline Active...");
        const formData = new FormData();
        files.forEach(f => formData.append('images', f));
        
        const initRes = await axios.post(`${API_URL}/api/predict/batch`, formData, config);
        const { jobId } = initRes.data;

        const intervalId = setInterval(async () => {
          try {
            const statusRes = await axios.get(`${API_URL}/api/predict/batch/${jobId}`, config);
            const job = statusRes.data;
            const pct = Math.round((job.processed / job.total) * 100);
            setProgress(pct);
            setStatusText(`Decoding: ${job.processed}/${job.total} samples`);

            if (job.status === 'completed') {
              clearInterval(intervalId);
              setIsAnalyzing(false);
              navigate('/batch-result', { state: { job } });
            }
          } catch (e) {
             clearInterval(intervalId);
             setIsAnalyzing(false);
          }
        }, 1000);
      }
    } catch (err) {
      console.error(err);
      setIsAnalyzing(false);
    }
  };

  return (
    <div className="max-w-6xl mx-auto space-y-12 animate-in font-manrope">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
          <div className="flex items-center gap-2 text-primary font-black text-[10px] uppercase tracking-[0.3em] mb-4">
             <Sparkles className="w-4 h-4 shadow-primary/50" /> New Material Audit
          </div>
          <h1 className="text-5xl font-black text-foreground tracking-tighter">Inference Hub</h1>
          <p className="text-muted-foreground mt-2 font-bold tracking-tight">Upload high-res fabric samples for hierarchical mapping.</p>
        </div>
      </div>

      <div className="grid lg:grid-cols-5 gap-12">
        {/* Upload Container */}
        <div className="lg:col-span-3 space-y-8">
          <div
            {...getRootProps()}
            className={`
              relative group rounded-[3rem] border-2 border-dashed transition-all duration-700 flex flex-col items-center justify-center min-h-[450px] overflow-hidden
              ${isDragActive ? 'border-primary bg-primary/5' : 'border-white/5 bg-[#1A1A1A] hover:bg-background/[0.02] hover:border-white/10'}
              ${isAnalyzing ? 'pointer-events-none opacity-50' : 'cursor-pointer'}
            `}
          >
            <input {...getInputProps()} />
            
            <AnimatePresence mode="wait">
              {isAnalyzing ? (
                <motion.div 
                  key="analyzing"
                  initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }}
                  className="flex flex-col items-center gap-8"
                >
                  <div className="relative">
                    <motion.div 
                      animate={{ rotate: 360 }} transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
                      className="w-32 h-32 rounded-full border-4 border-white/5 border-t-primary shadow-[0_0_30px_rgba(128,203,196,0.2)]"
                    />
                    <div className="absolute inset-0 flex items-center justify-center text-2xl font-black text-foreground tracking-tighter">
                      {progress}%
                    </div>
                  </div>
                  <div className="text-center">
                    <p className="text-foreground font-black text-2xl tracking-tighter mb-2">{statusText}</p>
                    <p className="text-muted-foreground text-xs font-black uppercase tracking-widest">EfficientNet Core: Validating Pixels</p>
                  </div>
                </motion.div>
              ) : (
                <motion.div 
                  key="idle"
                  initial={{ opacity: 0 }} animate={{ opacity: 1 }}
                  className="flex flex-col items-center text-center px-12"
                >
                  <div className="w-20 h-20 bg-background rounded-[1.75rem] flex items-center justify-center mb-10 shadow-[0_20px_40px_-10px_rgba(255,255,255,0.3)] group-hover:scale-110 transition-transform duration-500">
                    <Plus className="w-10 h-10 text-black" />
                  </div>
                  <h3 className="text-3xl font-black text-foreground mb-3 tracking-tighter">Drop samples here</h3>
                  <p className="text-muted-foreground text-sm font-bold max-w-[280px] leading-relaxed">Drag multiple images for industrial batch analysis. High precision guaranteed.</p>
                </motion.div>
              )}
            </AnimatePresence>
            
            {/* Mobile-style scanning line */}
            {isAnalyzing && (
              <motion.div 
                initial={{ top: '-10%' }} animate={{ top: '110%' }} transition={{ duration: 2.5, repeat: Infinity, ease: "linear" }}
                className="absolute left-0 w-full h-[3px] bg-gradient-to-r from-transparent via-primary to-transparent z-20 shadow-[0_0_20px_rgba(128,203,196,0.8)]"
              />
            )}
          </div>

          {/* Actions Bar */}
          <div className="glass-card p-8 rounded-[2.5rem] flex items-center justify-between border-white/[0.03]">
             <div className="flex -space-x-3">
                {previews.slice(0, 6).map((p, i) => (
                  <div key={i} className="w-12 h-12 rounded-full border-4 border-[#101010] bg-zinc-800 overflow-hidden relative shadow-xl">
                    <img src={p} className="w-full h-full object-cover" />
                  </div>
                ))}
                {previews.length > 6 && (
                  <div className="w-12 h-12 rounded-full border-4 border-[#101010] bg-muted/50 flex items-center justify-center text-[10px] font-black text-foreground shadow-xl">
                    +{previews.length - 6}
                  </div>
                )}
                {previews.length === 0 && (
                  <div className="text-muted-foreground text-xs font-black uppercase tracking-widest pl-4">Empty Queue</div>
                )}
             </div>
             
             <div className="flex gap-4">
                {files.length > 0 && !isAnalyzing && (
                  <button 
                    onClick={() => { setFiles([]); setPreviews([]); }}
                    className="secondary-button"
                  >
                    Reset
                  </button>
                )}
                <button
                  onClick={handleUpload}
                  disabled={files.length === 0 || isAnalyzing}
                  className="primary-button min-w-[200px]"
                >
                  {isAnalyzing ? (
                    <Loader2 className="w-6 h-6 animate-spin" />
                  ) : (
                    <>
                      Execute Inference
                      <ArrowRight className="w-5 h-5" />
                    </>
                  )}
                </button>
             </div>
          </div>
        </div>

        {/* Info Column */}
        <div className="lg:col-span-2 space-y-10">
           <div className="glass-card p-10 rounded-[3rem] border-white/[0.03] bg-background/[0.01]">
              <div className="flex items-center gap-4 mb-8">
                 <div className="p-4 rounded-2xl bg-secondary/10 text-secondary shadow-lg shadow-secondary/10">
                    <Layers className="w-7 h-7" />
                 </div>
                 <h3 className="text-2xl font-black text-foreground tracking-tighter">Compute Node</h3>
              </div>
              <div className="space-y-8">
                 {[
                   { label: 'Neural Engine', val: 'EfficientNet-B0' },
                   { label: 'Resolution', val: '224px Adaptive' },
                   { label: 'Precision', val: 'FP16 Half' },
                   { label: 'Batch limit', val: '50 Samples' }
                 ].map((item, i) => (
                   <div key={i} className="flex justify-between items-center border-b border-white/5 pb-4">
                      <span className="text-muted-foreground text-[10px] font-black uppercase tracking-widest">{item.label}</span>
                      <span className="text-foreground text-sm font-black tracking-tight">{item.val}</span>
                   </div>
                 ))}
              </div>
           </div>

           <div className="p-10 rounded-[3rem] bg-gradient-to-br from-primary to-emerald-600 relative overflow-hidden group shadow-2xl shadow-primary/10">
              <div className="relative z-10 text-black">
                 <h3 className="text-3xl font-black mb-3 tracking-tighter leading-none">Need faster training?</h3>
                 <p className="text-black/60 text-sm font-bold leading-relaxed mb-10 max-w-[200px]">Link your private H100 cluster for millisecond training cycles.</p>
                 <button className="w-full py-4 bg-slate-900 text-foreground font-black rounded-2xl text-sm hover:bg-muted/50 active:scale-95 transition-all shadow-2xl tracking-tight">
                    Request Enterprise Node
                 </button>
              </div>
              <Sparkles className="absolute -bottom-10 -right-10 w-40 h-40 text-black/10 rotate-12 group-hover:rotate-45 transition-transform duration-1000" />
           </div>
        </div>
      </div>
    </div>
  );
};

export default Upload;
