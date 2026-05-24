// Brand identity card — daana

function BrandCard() {
  return (
    <div className="daana" style={{
      width: '100%', height: '100%', background: DAANA.bg, padding: 56,
      display: 'grid', gridTemplateColumns: '1.1fr 1fr', gap: 56,
    }}>
      {/* Left — wordmark + tagline */}
      <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
        <Eyebrow>Brand · Identity 01</Eyebrow>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 28 }}>
          <div className="serif" style={{ fontFamily: DAANA.serif, fontSize: 180, lineHeight: 0.9, letterSpacing: '-0.035em' }}>
            daana<span style={{ color: DAANA.moss }}>.</span>
          </div>
          <div style={{ maxWidth: 460, fontSize: 18, lineHeight: 1.5, color: DAANA.ink70 }}>
            A quiet, premium pantry — fresh produce, daily essentials, and a small assistant who speaks both your languages.
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 24 }}>
            <span className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 38, color: DAANA.ink }}>دانہ</span>
            <Hr vertical style={{ height: 36 }} />
            <div>
              <Eyebrow>Means</Eyebrow>
              <div style={{ fontSize: 15, marginTop: 4 }}>a single grain, a seed of something to come</div>
            </div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 32, alignItems: 'flex-end' }}>
          <div>
            <Eyebrow>Markets</Eyebrow>
            <div style={{ marginTop: 6, fontSize: 14 }}>Karachi · Lahore · Islamabad</div>
          </div>
          <div>
            <Eyebrow>Languages</Eyebrow>
            <div style={{ marginTop: 6, fontSize: 14 }}>English · اردو</div>
          </div>
        </div>
      </div>

      {/* Right — system tiles */}
      <div style={{ display: 'grid', gridTemplateRows: '1fr 1fr 1fr', gap: 16 }}>
        {/* Palette */}
        <div style={{ background: DAANA.card, borderRadius: 16, padding: 20, display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Eyebrow>Palette</Eyebrow>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 8, flex: 1 }}>
            {[
              { c: DAANA.bg, n: 'paper', v: '#F6F3EC' },
              { c: DAANA.bgAlt, n: 'ecru', v: '#EFEBE0' },
              { c: DAANA.moss, n: 'moss', v: '#3D5A3A' },
              { c: DAANA.ink, n: 'ink', v: '#1A1814' },
              { c: DAANA.saffron, n: 'saffron', v: '#B8703A' },
            ].map((s, i) => (
              <div key={i} style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                <div style={{ flex: 1, background: s.c, borderRadius: 8, border: `1px solid ${DAANA.hairlineSoft}`, minHeight: 56 }} />
                <div style={{ fontFamily: DAANA.mono, fontSize: 9.5, color: DAANA.ink70, letterSpacing: '0.05em' }}>{s.n}</div>
                <div style={{ fontFamily: DAANA.mono, fontSize: 9, color: DAANA.ink30 }}>{s.v}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Type */}
        <div style={{ background: DAANA.card, borderRadius: 16, padding: 20, display: 'flex', flexDirection: 'column', gap: 10 }}>
          <Eyebrow>Type</Eyebrow>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, flex: 1 }}>
            <div>
              <div className="serif" style={{ fontSize: 44, lineHeight: 1, fontFamily: DAANA.serif }}>Aa</div>
              <div style={{ fontSize: 12, marginTop: 6 }}>Instrument Serif</div>
              <div style={{ fontFamily: DAANA.mono, fontSize: 10, color: DAANA.ink50 }}>display · headings</div>
            </div>
            <div>
              <div style={{ fontSize: 44, lineHeight: 1, fontFamily: DAANA.sans, fontWeight: 500 }}>Aa</div>
              <div style={{ fontSize: 12, marginTop: 6 }}>Geist</div>
              <div style={{ fontFamily: DAANA.mono, fontSize: 10, color: DAANA.ink50 }}>UI · body · prices</div>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, paddingTop: 10, borderTop: `1px solid ${DAANA.hairlineSoft}` }}>
            <span className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 28, color: DAANA.ink }}>اردو</span>
            <div>
              <div style={{ fontSize: 12 }}>Noto Nastaliq Urdu</div>
              <div style={{ fontFamily: DAANA.mono, fontSize: 10, color: DAANA.ink50 }}>bilingual surfaces</div>
            </div>
          </div>
        </div>

        {/* Principles */}
        <div style={{ background: DAANA.ink, color: DAANA.bg, borderRadius: 16, padding: 20, display: 'flex', flexDirection: 'column', gap: 10 }}>
          <Eyebrow style={{ color: 'rgba(246,243,236,0.5)' }}>Principles</Eyebrow>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, fontSize: 14, lineHeight: 1.4 }}>
            <div>01 &nbsp; Paper, never plastic — warm cream over screen white.</div>
            <div>02 &nbsp; One green. Moss is the only saturated color.</div>
            <div>03 &nbsp; Real produce photography. Never AI-drawn fruit.</div>
            <div>04 &nbsp; Bilingual by default. Urdu is a first-class citizen.</div>
            <div>05 &nbsp; AI is a quiet helper, not a hero.</div>
          </div>
        </div>
      </div>
    </div>
  );
}

window.BrandCard = BrandCard;
