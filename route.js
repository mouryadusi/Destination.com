export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({
      error: 'Method not allowed'
    });
  }

  if (!process.env.GROQ_API_KEY) {
    return res.status(500).json({
      error: 'GROQ_API_KEY is not configured in Vercel.'
    });
  }

  let body = req.body;

  if (typeof body === 'string') {
    try {
      body = JSON.parse(body);
    } catch {
      return res.status(400).json({
        error: 'Invalid JSON body.'
      });
    }
  }

  const query = String(
    body?.query ||
    body?.message ||
    ''
  ).trim();

  if (!query) {
    return res.status(400).json({
      error: 'No query provided.'
    });
  }

  /*
   * IMPORTANT:
   * This API does not pretend that Groq itself is live flight,
   * visa, NOTAM, or airport data.
   *
   * The AI is instructed to distinguish:
   * - verified information supplied to it
   * - estimates
   * - information that requires verification
   */

  const SYSTEM = `
You are the AI travel-routing engine for destination.com.

Your job is to understand the traveller's request and produce a useful,
honest travel recommendation.

CRITICAL ACCURACY RULES:

1. NEVER invent live flight prices.
2. NEVER invent flight schedules.
3. NEVER claim that a flight is currently operating unless verified data
   has been supplied in the context.
4. NEVER claim that visa requirements were checked against a database
   unless actual visa data was supplied.
5. NEVER claim that NOTAMs, airspace restrictions, or safety databases
   were checked unless actual data was supplied.
6. If live data is unavailable, clearly label information as an estimate
   or "verification required".
7. Never fabricate a source.
8. Never fabricate an airline.
9. Never fabricate an airport IATA code.
10. You may use your general knowledge to reason about likely routes,
    but do not represent that knowledge as live data.
11. If the user gives an airport code, preserve it.
12. If the user gives only cities, provide likely airports/routes but
    clearly indicate that the exact flight needs verification.
13. Be especially careful with visa and safety advice.
14. For US passport holders, do not assume visa-free entry unless verified.
15. Prices must be marked as estimates unless supplied by a real flight API.

Return ONLY valid JSON.

Use exactly this structure:

{
  "summary": "One warm sentence about the traveller's situation.",

  "ragSources": [
    "AI route reasoning"
  ],

  "bestSolution": {
    "title": "Route",
    "description": "2-3 useful sentences.",
    "cost": "Estimate or verification required",
    "time": "Estimated or verification required",
    "modality": "Flight / One stop flight / Multi-modal",
    "confidence": "High / Medium / Low",
    "highlights": [
      "Useful fact",
      "Route detail",
      "Practical tip"
    ]
  },

  "alternatives": [
    {
      "title": "Alternative route",
      "via": "Route",
      "cost": "Estimate or verification required",
      "time": "Estimate or verification required",
      "tradeoff": "Why choose this",
      "badge": "CHEAPEST"
    },
    {
      "title": "Alternative route",
      "via": "Route",
      "cost": "Estimate or verification required",
      "time": "Estimate or verification required",
      "tradeoff": "Why choose this",
      "badge": "FASTEST"
    }
  ],

  "safetyTips": [
    "Visa verification guidance",
    "Airspace/safety verification guidance",
    "Journey tip",
    "Destination tip"
  ],

  "articles": [
    {
      "title": "Planning guidance",
      "description": "One sentence.",
      "readTime": "5 min read",
      "category": "Planning"
    },
    {
      "title": "Travel safety guidance",
      "description": "One sentence.",
      "readTime": "4 min read",
      "category": "Safety"
    },
    {
      "title": "Destination guidance",
      "description": "One sentence.",
      "readTime": "6 min read",
      "category": "Culture"
    }
  ],

  "communityInsights": {
    "activeUsers": 0,
    "insight": "Community data is not currently verified.",
    "tips": [
      "Check current traveller reports before departure.",
      "Verify operational details close to departure."
    ]
  },

  "disclaimer": "Prices, schedules, visa rules and safety conditions must be verified against current official or live sources before travel."
}
`;

  try {
    const groqResponse = await fetch(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        method: 'POST',

        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.GROQ_API_KEY}`
        },

        body: JSON.stringify({
          /*
           * llama-3.3-70b-versatile was deprecated.
           * Use the currently recommended Groq model.
           */
          model: 'openai/gpt-oss-120b',

          messages: [
            {
              role: 'system',
              content: SYSTEM
            },
            {
              role: 'user',
              content: query
            }
          ],

          temperature: 0.2,

          max_tokens: 3000,

          response_format: {
            type: 'json_object'
          }
        })
      }
    );

    if (!groqResponse.ok) {
      const errorText = await groqResponse.text();

      console.error('Groq error:', errorText);

      return res.status(502).json({
        error: 'Groq API error.',
        details: errorText.slice(0, 500)
      });
    }

    const data = await groqResponse.json();

    const raw =
      data?.choices?.[0]?.message?.content?.trim();

    if (!raw) {
      return res.status(502).json({
        error: 'Groq returned an empty response.'
      });
    }

    let parsed;

    try {
      parsed = JSON.parse(raw);
    } catch (error) {
      console.error('JSON parse error:', raw);

      return res.status(502).json({
        error: 'AI returned invalid JSON.'
      });
    }

    /*
     * Basic response validation.
     */

    if (
      !parsed ||
      typeof parsed !== 'object' ||
      !parsed.bestSolution
    ) {
      return res.status(502).json({
        error: 'AI returned an incomplete travel response.'
      });
    }

    /*
     * Safety fallback:
     * Never allow the frontend to display fake live-source claims.
     */

    if (!Array.isArray(parsed.ragSources)) {
      parsed.ragSources = ['AI route reasoning'];
    }

    if (
      parsed.ragSources.some(
        source =>
          typeof source === 'string' &&
          /live flight data|visa requirements db|iata route database/i.test(
            source
          )
      )
    ) {
      parsed.ragSources = parsed.ragSources.filter(
        source =>
          !/live flight data|visa requirements db|iata route database/i.test(
            source
          )
      );

      parsed.ragSources.unshift('AI route reasoning');
    }

    if (!parsed.disclaimer) {
      parsed.disclaimer =
        'Prices, schedules, visa rules and safety conditions must be verified against current official or live sources before travel.';
    }

    return res.status(200).json(parsed);

  } catch (error) {
    console.error('Route API error:', error);

    return res.status(500).json({
      error: 'Travel analysis failed.',
      details:
        process.env.NODE_ENV === 'development'
          ? error.message
          : undefined
    });
  }
}
