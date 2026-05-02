import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowRightLeft, Scale, Search } from 'lucide-react';
import axios from 'axios';

// Hardcoded for the UI, ideally fetched from backend
const DENIM_CLASSES = [
  "138-CG", "1553-EL", "1583-EM", "1600-JK", "1780-A", "1830-BE", "1830-BZ",
  "1952-BC", "1965-G", "1976-W", "2034-A", "2051", "P140394I", "P140406BB",
  "P140541", "P140676", "P140813", "P140858", "P140901", "PRP180CA", "PRT0235AY"
];

const ClassComparison = () => {
  const [classA, setClassA] = useState(DENIM_CLASSES[0]);
  const [classB, setClassB] = useState(DENIM_CLASSES[1]);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleCompare = async () => {
    if (classA === classB) {
      alert("Please select two different classes.");
      return;
    }
    
    setLoading(true);
    try {
      const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
      const res = await axios.get(`http://localhost:5000/api/analytics/class-comparison?classA=${classA}&classB=${classB}`, config);
      setData(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-8 max-w-7xl mx-auto animate-in">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-foreground mb-2 flex items-center gap-3">
          <Scale className="text-indigo-400" />
          Class Comparison
        </h1>
        <p className="text-muted-foreground">Pit two denim classes against each other to analyze their performance.</p>
      </div>

      <div className="glass-card rounded-3xl p-8 mb-8">
        <div className="flex flex-col md:flex-row items-center gap-6">
          <div className="flex-1 w-full">
            <label className="block text-sm font-medium text-muted-foreground mb-2">Class A</label>
            <select 
              value={classA} 
              onChange={(e) => setClassA(e.target.value)}
              className="w-full bg-background border border-border rounded-xl px-4 py-3 text-foreground focus:outline-none focus:border-indigo-500 transition-colors"
            >
              {DENIM_CLASSES.map(c => <option key={c} value={c} className="bg-background text-foreground">{c}</option>)}
            </select>
          </div>
          
          <div className="w-12 h-12 rounded-full bg-background/5 flex items-center justify-center shrink-0 hidden md:flex mt-6">
            <ArrowRightLeft className="w-5 h-5 text-gray-500" />
          </div>

          <div className="flex-1 w-full">
            <label className="block text-sm font-medium text-muted-foreground mb-2">Class B</label>
            <select 
              value={classB} 
              onChange={(e) => setClassB(e.target.value)}
              className="w-full bg-background border border-border rounded-xl px-4 py-3 text-foreground focus:outline-none focus:border-indigo-500 transition-colors"
            >
              {DENIM_CLASSES.map(c => <option key={c} value={c} className="bg-background text-foreground">{c}</option>)}
            </select>
          </div>

          <div className="md:mt-7 w-full md:w-auto">
            <button 
              onClick={handleCompare}
              disabled={loading}
              className="w-full md:w-auto px-8 py-3 bg-indigo-600 hover:bg-indigo-700 text-foreground rounded-xl font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Search className="w-4 h-4" />
              {loading ? 'Analyzing...' : 'Compare'}
            </button>
          </div>
        </div>
      </div>

      {data && (
        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
          className="grid md:grid-cols-2 gap-8"
        >
          {/* Class A Stats */}
          <div className="glass-card rounded-3xl p-8 border-indigo-500/30">
            <h2 className="text-3xl font-bold text-foreground mb-6 text-center">{data.classA.name}</h2>
            <div className="space-y-6">
              <div className="bg-background/50 p-4 rounded-2xl flex justify-between items-center border border-border/50">
                <span className="text-muted-foreground">Total Scans in Database</span>
                <span className="text-2xl font-bold text-foreground">{data.classA.count}</span>
              </div>
              <div className="bg-background/50 p-4 rounded-2xl flex justify-between items-center border border-border/50">
                <span className="text-muted-foreground">Average Confidence</span>
                <span className="text-2xl font-bold text-indigo-500">{(data.classA.avgConfidence * 100).toFixed(1)}%</span>
              </div>
            </div>
          </div>

          {/* Class B Stats */}
          <div className="glass-card rounded-3xl p-8 border-purple-500/30">
            <h2 className="text-3xl font-bold text-foreground mb-6 text-center">{data.classB.name}</h2>
            <div className="space-y-6">
              <div className="bg-background/50 p-4 rounded-2xl flex justify-between items-center border border-border/50">
                <span className="text-muted-foreground">Total Scans in Database</span>
                <span className="text-2xl font-bold text-foreground">{data.classB.count}</span>
              </div>
              <div className="bg-background/50 p-4 rounded-2xl flex justify-between items-center border border-border/50">
                <span className="text-muted-foreground">Average Confidence</span>
                <span className="text-2xl font-bold text-purple-500">{(data.classB.avgConfidence * 100).toFixed(1)}%</span>
              </div>
            </div>
          </div>
        </motion.div>
      )}

    </div>
  );
};

export default ClassComparison;
