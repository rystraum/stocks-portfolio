import React, { useEffect, useRef, useState } from 'react';
import { createChart, LineSeries, CandlestickSeries } from 'lightweight-charts';

const CompanyChart = ({ ticker }) => {
  const chartContainerRef = useRef(null);
  const chartRef = useRef(null);
  const seriesRef = useRef(null);
  const [range, setRange] = useState('30d');
  const [hasOhlc, setHasOhlc] = useState(false);

  const ranges = [
    { key: '30d', label: '30 Days' },
    { key: '3m', label: '3 Months' },
    { key: '12m', label: '12 Months' },
  ];

  useEffect(() => {
    if (!chartContainerRef.current) return;

    const chart = createChart(chartContainerRef.current, {
      layout: {
        background: { type: 'solid', color: '#ffffff' },
        textColor: '#333',
      },
      grid: {
        vertLines: { color: '#f0f0f0' },
        horzLines: { color: '#f0f0f0' },
      },
      rightPriceScale: {
        borderColor: '#cccccc',
      },
      timeScale: {
        borderColor: '#cccccc',
        timeVisible: true,
      },
      height: 400,
    });

    chartRef.current = chart;

    const handleResize = () => {
      if (chartContainerRef.current) {
        chart.applyOptions({ width: chartContainerRef.current.clientWidth });
      }
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
      chart.remove();
    };
  }, []);

  useEffect(() => {
    if (!chartRef.current || !ticker) return;

    const daysMap = { '30d': 30, '3m': 90, '12m': 365 };
    const days = daysMap[range];
    const since = new Date();
    since.setDate(since.getDate() - days);

    fetch(`/companies/${ticker}/price_updates.json`)
      .then((res) => res.json())
      .then((data) => {
        // Sort by datetime ascending, then deduplicate by date (keep last per day)
        const sorted = data
          .filter((d) => new Date(d.datetime) >= since)
          .sort((a, b) => new Date(a.datetime) - new Date(b.datetime));

        const byDate = new Map();
        sorted.forEach((d) => {
          const dateKey = d.datetime.split('T')[0];
          byDate.set(dateKey, d);
        });
        const filtered = Array.from(byDate.values());

        const hasOhlcData = filtered.some((d) => d.open && d.high && d.low);
        setHasOhlc(hasOhlcData);

        const chart = chartRef.current;
        if (seriesRef.current) {
          chart.removeSeries(seriesRef.current);
          seriesRef.current = null;
        }

        if (hasOhlcData) {
          seriesRef.current = chart.addSeries(CandlestickSeries, {
            upColor: '#26a69a',
            downColor: '#ef5350',
            borderVisible: false,
            wickUpColor: '#26a69a',
            wickDownColor: '#ef5350',
          });

          seriesRef.current.setData(
            filtered.map((d) => ({
              time: d.datetime.split('T')[0],
              open: parseFloat(d.open),
              high: parseFloat(d.high),
              low: parseFloat(d.low),
              close: parseFloat(d.price),
            }))
          );
        } else {
          seriesRef.current = chart.addSeries(LineSeries, {
            color: '#2962FF',
            lineWidth: 2,
          });

          seriesRef.current.setData(
            filtered.map((d) => ({
              time: d.datetime.split('T')[0],
              value: parseFloat(d.price),
            }))
          );
        }

        chart.timeScale().fitContent();
      });
  }, [ticker, range]);

  return (
    <div className="card">
      <div className="card-header flex justify-between items-center">
        <h4 className="card-header-title">Price Chart</h4>
        <div className="flex gap-2">
          {ranges.map((r) => (
            <button
              key={r.key}
              onClick={() => setRange(r.key)}
              className={`px-3 py-1 text-sm rounded ${
                range === r.key
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
              }`}
            >
              {r.label}
            </button>
          ))}
        </div>
      </div>
      <div className="card-body">
        {hasOhlc && (
          <p className="text-xs text-gray-500 mb-2">Candlestick chart</p>
        )}
        {!hasOhlc && (
          <p className="text-xs text-gray-500 mb-2">Line chart (OHLC not available)</p>
        )}
        <div ref={chartContainerRef} style={{ width: '100%', height: '400px' }} />
      </div>
    </div>
  );
};

export default CompanyChart;
