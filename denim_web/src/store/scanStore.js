import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useScanStore = create(
  persist(
    (set) => ({
      currentScan: null,
      scanHistory: [],
      flaggedQueue: [],
      
      setCurrentScan: (scan) => set({ currentScan: scan }),
      
      addScanToHistory: (scan) => set((state) => ({ 
        scanHistory: [
          { ...scan, id: Date.now().toString(), timestamp: new Date().toISOString() }, 
          ...state.scanHistory
        ] 
      })),
      
      addFlaggedScan: (scan) => set((state) => ({
        flaggedQueue: [
          { ...scan, id: Date.now().toString(), timestamp: new Date().toISOString() },
          ...state.flaggedQueue
        ]
      })),

      resolveFlaggedScan: (id) => set((state) => ({
        flaggedQueue: state.flaggedQueue.filter(s => s.id !== id)
      })),

      clearHistory: () => set({ scanHistory: [], flaggedQueue: [] }),
      clearCurrentScan: () => set({ currentScan: null })
    }),
    {
      name: 'denimai-scan-storage', // name of the item in the storage (must be unique)
    }
  )
);
