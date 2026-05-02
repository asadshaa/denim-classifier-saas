import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Database, Filter, Search, ChevronLeft, ChevronRight, AlertTriangle, CheckCircle2, XCircle } from 'lucide-react';
import axios from 'axios';

const DatasetExplorer = () => {
  const [dataset, setDataset] = useState([]);
  const [classes, setClasses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  
  // Filters
  const [filterClass, setFilterClass] = useState('');
  const [filterFeedback, setFilterFeedback] = useState('');
  const [filterLowConf, setFilterLowConf] = useState(false);

  useEffect(() => {
    fetchClasses();
  }, []);

  useEffect(() => {
    fetchDataset();
  }, [page, filterClass, filterFeedback, filterLowConf]);

  const fetchClasses = async () => {
    try {
      const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
      const res = await axios.get('http://localhost:5000/api/dataset/classes', config);
      setClasses(res.data);
    } catch (err) {
      console.error('Error fetching classes:', err);
    }
  };

  const fetchDataset = async () => {
    setLoading(true);
    try {
      const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
      let url = `http://localhost:5000/api/dataset?page=${page}&limit=12`;
      if (filterClass) url += `&main_class=${filterClass}`;
      if (filterFeedback) url += `&feedback=${filterFeedback}`;
      if (filterLowConf) url += `&low_confidence=true`;

      const res = await axios.get(url, config);
      setDataset(res.data.predictions);
      setTotalPages(res.data.totalPages);
      setTotalItems(res.data.totalItems);
    } catch (err) {
      console.error('Error fetching dataset:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8 animate-in font-manrope pb-20">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
          <div className="flex items-center gap-3 mb-2 text-primary">
             <Database className="w-6 h-6" />
             <span className="font-black text-xs uppercase tracking-[0.3em]">Data Engineering</span>
          </div>
          <h1 className="text-4xl md:text-5xl font-black text-foreground tracking-tighter">Dataset Explorer</h1>
          <p className="text-muted-foreground mt-3 font-bold max-w-2xl">Browse, filter, and curate your historical inference data for Active Learning pipelines.</p>
        </div>
        <div className="text-right">
           <span className="text-4xl font-black text-primary tracking-tighter">{totalItems}</span>
           <span className="block text-[10px] font-black uppercase text-muted-foreground tracking-widest mt-1">Total Scans</span>
        </div>
      </div>

      <div className="glass-card p-6 rounded-3xl flex flex-wrap gap-4 items-center">
        <div className="flex items-center gap-2 text-muted-foreground font-bold mr-4">
          <Filter className="w-4 h-4" /> Filters:
        </div>
        
        <select 
          value={filterClass} 
          onChange={(e) => { setFilterClass(e.target.value); setPage(1); }}
          className="bg-background border border-border rounded-xl px-4 py-2 text-sm text-foreground focus:outline-none focus:border-primary"
        >
          <option value="">All Classes</option>
          {classes.map(c => <option key={c} value={c}>{c}</option>)}
        </select>

        <select 
          value={filterFeedback} 
          onChange={(e) => { setFilterFeedback(e.target.value); setPage(1); }}
          className="bg-background border border-border rounded-xl px-4 py-2 text-sm text-foreground focus:outline-none focus:border-primary"
        >
          <option value="">All Feedback</option>
          <option value="correct">Verified Correct</option>
          <option value="incorrect">Flagged Incorrect</option>
          <option value="null">Unverified</option>
        </select>

        <label className="flex items-center gap-2 cursor-pointer bg-background border border-border rounded-xl px-4 py-2">
          <input 
            type="checkbox" 
            checked={filterLowConf} 
            onChange={(e) => { setFilterLowConf(e.target.checked); setPage(1); }}
            className="accent-primary"
          />
          <span className="text-sm font-bold text-foreground">Low Confidence (&lt;80%)</span>
        </label>
        
        {(filterClass || filterFeedback || filterLowConf) && (
          <button 
            onClick={() => { setFilterClass(''); setFilterFeedback(''); setFilterLowConf(false); setPage(1); }}
            className="text-xs font-bold text-red-500 hover:text-red-400 ml-auto"
          >
            Clear Filters
          </button>
        )}
      </div>

      {loading ? (
        <div className="py-20 text-center">
          <div className="w-10 h-10 border-4 border-primary/20 border-t-primary rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-muted-foreground font-bold">Querying Database...</p>
        </div>
      ) : dataset.length === 0 ? (
        <div className="glass-card py-20 text-center rounded-3xl">
          <Search className="w-12 h-12 text-muted-foreground/30 mx-auto mb-4" />
          <h3 className="text-xl font-black text-foreground mb-2">No results found</h3>
          <p className="text-muted-foreground text-sm font-bold">Try adjusting your filters to see more data.</p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            {dataset.map((item) => (
              <motion.div 
                key={item._id}
                initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
                className="glass-card rounded-[2rem] p-5 overflow-hidden group flex flex-col"
              >
                <div className="aspect-video rounded-xl overflow-hidden mb-4 relative bg-muted">
                  <img src={`http://localhost:5000${item.imageUrl}`} alt="Scan" className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                  <div className="absolute top-2 right-2 flex gap-2">
                    {item.feedback === 'correct' && <div className="bg-emerald-500/90 text-white p-1 rounded-lg backdrop-blur-sm"><CheckCircle2 className="w-4 h-4" /></div>}
                    {item.feedback === 'incorrect' && <div className="bg-red-500/90 text-white p-1 rounded-lg backdrop-blur-sm"><XCircle className="w-4 h-4" /></div>}
                    {item.confidence_main < 0.8 && <div className="bg-amber-500/90 text-white p-1 rounded-lg backdrop-blur-sm"><AlertTriangle className="w-4 h-4" /></div>}
                  </div>
                </div>
                
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h4 className="font-black text-foreground text-lg tracking-tight">{item.main_class}</h4>
                    <p className="text-xs font-bold text-muted-foreground">V{item.subclass}</p>
                  </div>
                  <div className="text-right">
                    <span className={`text-xl font-black tracking-tighter ${item.confidence_main >= 0.8 ? 'text-primary' : 'text-amber-500'}`}>
                      {(item.confidence_main * 100).toFixed(1)}%
                    </span>
                  </div>
                </div>
                
                <div className="mt-auto pt-4 border-t border-border flex justify-between text-[10px] font-black uppercase tracking-widest text-muted-foreground/70">
                  <span>{new Date(item.timestamp).toLocaleDateString()}</span>
                  <span>{item.inference_time_ms ? `${item.inference_time_ms}ms` : 'N/A'} • {item.model_version || 'v1.0'}</span>
                </div>
              </motion.div>
            ))}
          </div>

          {totalPages > 1 && (
            <div className="flex justify-center items-center gap-4 mt-12">
              <button 
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="p-2 rounded-xl bg-card border border-border text-foreground disabled:opacity-50 hover:bg-muted transition-colors"
              >
                <ChevronLeft className="w-5 h-5" />
              </button>
              <span className="text-sm font-bold text-muted-foreground">Page {page} of {totalPages}</span>
              <button 
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="p-2 rounded-xl bg-card border border-border text-foreground disabled:opacity-50 hover:bg-muted transition-colors"
              >
                <ChevronRight className="w-5 h-5" />
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default DatasetExplorer;
