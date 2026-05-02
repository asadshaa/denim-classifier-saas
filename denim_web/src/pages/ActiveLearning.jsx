import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { useAuthStore } from '../store/authStore';
import { Layers, Check, X, AlertTriangle, Database } from 'lucide-react';
import { useScanStore } from '../store/scanStore';

const ActiveLearning = () => {
  const { isAuthenticated } = useAuthStore();
  const { flaggedQueue, resolveFlaggedScan } = useScanStore();
  const [loading, setLoading] = useState(false);

  // Use flaggedQueue directly
  const scans = flaggedQueue;

  const handleFeedback = (id, feedbackType) => {
    // In a real app, send to backend. Here, just remove from queue.
    resolveFlaggedScan(id);
  };

  return (
    <div className="p-8 max-w-7xl mx-auto animate-in">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-foreground mb-2 flex items-center gap-3">
          <Layers className="text-indigo-400" />
          Active Learning
        </h1>
        <p className="text-gray-400">Review low-confidence predictions to improve future model training.</p>
      </div>

      <div className="glass-card rounded-3xl p-6 border-amber-500/30">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-2">
            <AlertTriangle className="w-5 h-5 text-amber-400" />
            <h2 className="text-xl font-semibold text-foreground">Needs Review</h2>
          </div>
          <span className="bg-amber-400/10 text-amber-400 px-3 py-1 rounded-full text-sm font-medium">
            {scans.length} Pending
          </span>
        </div>

        {loading ? (
          <div className="text-center py-12 text-gray-500 animate-pulse">Loading edge cases...</div>
        ) : scans.length === 0 ? (
          <div className="text-center py-16">
            <div className="w-16 h-16 bg-emerald-500/10 text-emerald-400 rounded-full flex items-center justify-center mx-auto mb-4">
              <Check className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-medium text-foreground mb-2">You're all caught up!</h3>
            <p className="text-gray-400">There are no low-confidence predictions requiring human review.</p>
          </div>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {scans.map(scan => (
              <motion.div 
                key={scan._id}
                layout
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className="bg-[#0a0a0a] border border-white/10 rounded-2xl overflow-hidden flex flex-col"
              >
                <div className="h-48 w-full relative bg-background/5 flex items-center justify-center">
                  {scan.imageUrl ? (
                    <img src={`http://localhost:5000${scan.imageUrl}`} alt="Fabric" className="w-full h-full object-cover" />
                  ) : (
                    <Database className="w-10 h-10 text-muted-foreground" />
                  )}
                  <div className="absolute top-2 right-2 bg-slate-900/70 backdrop-blur-md px-2 py-1 rounded text-xs font-bold text-red-400">
                    {(scan.confidence_main * 100).toFixed(1)}% Conf
                  </div>
                </div>
                
                <div className="p-5 flex-1 flex flex-col">
                  <p className="text-xs text-gray-500 mb-1">{new Date(scan.timestamp).toLocaleString()}</p>
                  <h3 className="text-lg font-bold text-foreground leading-tight">{scan.main_class}</h3>
                  <p className="text-sm text-gray-400 mb-6">Variant {scan.subclass}</p>
                  
                  <div className="mt-auto grid grid-cols-2 gap-3">
                    <button 
                      onClick={() => handleFeedback(scan.id, 'incorrect')}
                      className="flex items-center justify-center gap-2 py-2 rounded-xl bg-red-500/10 text-red-400 hover:bg-red-500/20 transition-colors font-medium text-sm"
                    >
                      <X className="w-4 h-4" /> Discard
                    </button>
                    <button 
                      onClick={() => handleFeedback(scan.id, 'correct')}
                      className="flex items-center justify-center gap-2 py-2 rounded-xl bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20 transition-colors font-medium text-sm"
                    >
                      <Check className="w-4 h-4" /> Approve
                    </button>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ActiveLearning;
