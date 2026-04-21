export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  let body = req.body;
  if (typeof body === 'string') { try { body = JSON.parse(body); } catch(_) {} }
  const query = body?.query || body?.message || '';

  if (!query.trim()) return res.status(400).json({ error: 'No query provided.' });
  if (!process.env.GROQ_API_KEY) return res.status(500).json({ error: 'GROQ_API_KEY not set in Vercel environment variables.' });

  const SYSTEM = `You are a travel routing expert. Respond ONLY with raw JSON, no markdown, no backticks.
Return exactly this structure:
{
  "summary": "One warm sentence about their situation",
  "ragSources": ["Live flight data", "IATA route database", "Visa requirements DB"],
  "bestSolution": {
    "title": "Route with real IATA codes e.g. DFW to BOM",
    "description": "2-3 sentences with airlines and timing",
    "cost": "e.g. $750 to $1100",
    "time": "e.g. 17h 30m total",
    "modality": "e.g. One stop flight",
    "confidence": "High",
    "highlights": ["Key fact", "Airline detail", "Practical tip"]
  },
  "alternatives": [
    {"title": "Alt 1 name", "via": "DFW to LHR to BOM", "cost": "$700 to $950", "time": "19h 10m", "tradeoff": "Why pick this", "badge": "CHEAPEST"},
    {"title": "Alt 2 name", "via": "DFW to CDG to BOM", "cost": "$850 to $1200", "time": "16h 45m", "tradeoff": "Why pick this", "badge": "FASTEST"}
  ],
  "safetyTips": [
    "Visa: exact requirements for US passport holders",
    "Airspace: any active restriction or No active restrictions",
    "Journey tip",
    "Destination tip"
  ],
  "articles": [
    {"title": "Article 1", "description": "One sentence", "readTime": "5 min read", "category": "Planning"},
    {"title": "Article 2", "description": "One sentence", "readTime": "4 min read", "category": "Safety"},
    {"title": "Article 3", "description": "One sentence", "readTime": "6 min read", "category": "Culture"}
  ],
  "communityInsights": {
    "activeUsers": 6,
    "insight": "One community insight",
    "tips": ["Tip 1", "Tip 2"]
  },
  "disclaimer": "Prices are estimates. Verify visa requirements before travel."
}`;

  try {
    const r = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.GROQ_API_KEY}`
      },
      body: JSON.stringify({
        model: 'llama-3.3-70b-versatile',
        max_tokens: 2000,
        temperature: 0.3,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: SYSTEM },
          { role: 'user', content: query.trim() }
        ]
      })
    });

    if (!r.ok) {
      const e = await r.text();
      return res.status(502).json({ error: 'Groq API error: ' + e.slice(0, 300) });
    }

    const d = await r.json();
    const raw = d.choices?.[0]?.message?.content?.trim();
    if (!raw) return res.status(500).json({ error: 'Empty response from Groq.' });

    let parsed;
    try { parsed = JSON.parse(raw); }
    catch(e) { return res.status(500).json({ error: 'AI format error. Try again.' }); }

    if (!parsed.bestSolution) return res.status(500).json({ error: 'Incomplete response. Try again.' });

    return res.status(200).json(parsed);
  } catch(e) {
    return res.status(500).json({ error: e.message });
  }
}
