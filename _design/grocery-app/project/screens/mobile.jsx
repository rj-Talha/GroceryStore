// Mobile screens — daana
// Designed for IOSDevice (402 × 874)

function MobileHome() {
  const cats = [
    { l: 'Fruits', u: 'پھل', t: 'c' },
    { l: 'Veg', u: 'سبزی', t: 'b' },
    { l: 'Meat', u: 'گوشت', t: 'a' },
    { l: 'Dairy', u: 'دودھ', t: 'd' },
    { l: 'Bakery', u: 'بیکری', t: 'c' },
    { l: 'Pantry', u: 'راشن', t: 'd' },
    { l: 'Drinks', u: 'مشروبات', t: 'b' },
    { l: 'Home', u: 'گھر', t: 'e' },
  ];

  return (
    <div className="daana scroll" style={{
      width: '100%', height: '100%', background: DAANA.bg, overflow: 'auto',
      paddingBottom: 100,
    }}>
      {/* Top — address bar */}
      <div style={{ padding: '60px 20px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <Eyebrow style={{ fontSize: 9.5 }}>Delivering today, 6 – 8 pm</Eyebrow>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4 }}>
            <Icon name="pin" size={15} color={DAANA.moss} />
            <span style={{ fontSize: 15 }}>DHA Phase VI</span>
            <Icon name="chevD" size={14} color={DAANA.ink50} />
          </div>
        </div>
        <button style={{
          width: 40, height: 40, borderRadius: 999, background: DAANA.card,
          border: `1px solid ${DAANA.hairlineSoft}`, display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="user" size={17} />
        </button>
      </div>

      {/* Search */}
      <div style={{ padding: '4px 20px 12px', display: 'flex', gap: 10 }}>
        <div style={{
          flex: 1, height: 48, borderRadius: 14, background: DAANA.card,
          border: `1px solid ${DAANA.hairlineSoft}`, display: 'flex', alignItems: 'center', padding: '0 14px', gap: 10,
        }}>
          <Icon name="search" size={16} color={DAANA.ink50} />
          <span style={{ fontSize: 14, color: DAANA.ink50, flex: 1 }}>Search "ٹماٹر" or "atta"</span>
        </div>
        <button style={{
          width: 48, height: 48, borderRadius: 14, background: DAANA.ink, border: 'none',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="mic" size={18} color={DAANA.bg} />
        </button>
      </div>

      {/* Hero */}
      <div style={{ padding: '4px 20px 20px' }}>
        <div style={{
          background: DAANA.ink, color: DAANA.bg, borderRadius: 20, padding: 20, position: 'relative', overflow: 'hidden',
        }}>
          <Eyebrow style={{ color: 'rgba(246,243,236,0.55)', fontSize: 9.5 }}>This week</Eyebrow>
          <div className="serif" style={{ fontFamily: DAANA.serif, fontSize: 38, lineHeight: 0.95, margin: '8px 0 12px', letterSpacing: '-0.02em', maxWidth: 240 }}>
            Mangoes have <em style={{ color: '#C8B583', fontStyle: 'italic' }}>landed.</em>
          </div>
          <div style={{ fontSize: 13, color: 'rgba(246,243,236,0.7)', lineHeight: 1.45, maxWidth: 220, marginBottom: 16 }}>
            Five varietals from Mirpurkhas. Delivered today.
          </div>
          <button style={{
            background: DAANA.bg, color: DAANA.ink, border: 'none', height: 38, padding: '0 16px', borderRadius: 999,
            fontSize: 13, display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            Shop the list <Icon name="arrowR" size={13} />
          </button>
          <div style={{ position: 'absolute', right: -20, top: 16, width: 140, height: 140, opacity: 0.9 }}>
            <ProductPlaceholder label="mango" tone="c" radius={70} />
          </div>
        </div>
      </div>

      {/* Categories */}
      <div style={{ padding: '4px 20px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
          <h3 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 22, margin: 0, letterSpacing: '-0.01em' }}>Categories</h3>
          <span style={{ fontSize: 12, color: DAANA.moss }}>See all</span>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10 }}>
          {cats.map((c, i) => (
            <div key={i} style={{
              background: DAANA.card, borderRadius: 14, padding: 10,
              border: `1px solid ${DAANA.hairlineSoft}`, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
            }}>
              <div style={{ width: 48, height: 48 }}>
                <ProductPlaceholder label="" tone={c.t} radius={10} />
              </div>
              <div style={{ fontSize: 11.5, textAlign: 'center', lineHeight: 1.1 }}>{c.l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* AI tile */}
      <div style={{ padding: '12px 20px 8px' }}>
        <div style={{
          background: '#283D26', color: DAANA.bg, borderRadius: 20, padding: 20, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
            <Icon name="sparkle" size={13} color="rgba(246,243,236,0.7)" />
            <Eyebrow style={{ color: 'rgba(246,243,236,0.55)', fontSize: 9.5 }}>Assistant</Eyebrow>
          </div>
          <div className="serif" style={{ fontFamily: DAANA.serif, fontSize: 26, lineHeight: 1.05, letterSpacing: '-0.01em', maxWidth: 240 }}>
            What's in your fridge tonight?
          </div>
          <div style={{ fontSize: 12.5, color: 'rgba(246,243,236,0.7)', lineHeight: 1.45, marginTop: 8 }}>
            We'll suggest three things to cook.
          </div>
          <button style={{
            marginTop: 14, background: 'rgba(246,243,236,0.12)', color: DAANA.bg,
            border: '1px solid rgba(246,243,236,0.18)', height: 36, padding: '0 14px', borderRadius: 999,
            fontSize: 13, display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            Open assistant <Icon name="arrowR" size={13} />
          </button>
        </div>
      </div>

      {/* Recommendations */}
      <div style={{ padding: '16px 0 8px' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '0 20px 12px' }}>
          <div>
            <Eyebrow style={{ fontSize: 9.5 }}>For you</Eyebrow>
            <h3 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 22, margin: '2px 0 0', letterSpacing: '-0.01em' }}>Picked for your pantry</h3>
          </div>
        </div>
        <div className="scroll" style={{ display: 'flex', gap: 12, overflowX: 'auto', padding: '0 20px 12px' }}>
          {[
            { ...PRODUCTS.mangoesSindhri, reason: 'Peak season' },
            { ...PRODUCTS.chai, reason: 'Buy every 3 wks' },
            { ...PRODUCTS.basmati, reason: 'Running low' },
            { ...PRODUCTS.chickenBreast, reason: 'On offer' },
          ].map((p, i) => (
            <div key={i} style={{ width: 168, flexShrink: 0 }}>
              <div style={{
                background: DAANA.card, borderRadius: 14, padding: 10, border: `1px solid ${DAANA.hairlineSoft}`,
                display: 'flex', flexDirection: 'column', gap: 8,
              }}>
                <div style={{ position: 'relative' }}>
                  <ProductPlaceholder label={p.label} tone={p.tone} radius={10} />
                  <button style={{
                    position: 'absolute', bottom: 6, right: 6, width: 26, height: 26, borderRadius: 999,
                    background: DAANA.ink, color: DAANA.bg, border: 'none',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    <Icon name="plus" size={12} color={DAANA.bg} />
                  </button>
                </div>
                <div>
                  <div style={{ fontSize: 13, lineHeight: 1.2 }}>{p.name}</div>
                  <div style={{ fontSize: 11, color: DAANA.ink50 }}>{p.unit}</div>
                </div>
                <div style={{ fontSize: 10.5, color: DAANA.moss, display: 'flex', alignItems: 'center', gap: 4 }}>
                  <Icon name="sparkle" size={10} color={DAANA.moss} />
                  {p.reason}
                </div>
                <Price value={p.price} size={14} />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Seasonal */}
      <div style={{ padding: '16px 20px 16px' }}>
        <div style={{ marginBottom: 12 }}>
          <Eyebrow style={{ fontSize: 9.5 }}>In season · May</Eyebrow>
          <h3 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 22, margin: '2px 0 0', letterSpacing: '-0.01em' }}>The mango list</h3>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 10 }}>
          {[
            { name: 'Sindhri', unit: '1 kg · sweet', price: 320, label: 'sindhri', tone: 'c' },
            { name: 'Chaunsa', unit: '1 kg · honeyed', price: 380, label: 'chaunsa', tone: 'c' },
          ].map((p, i) => (
            <ProductCard key={i} p={p} onAdd={() => {}} compact />
          ))}
        </div>
      </div>

      {/* Bottom nav */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, height: 80, background: DAANA.bg,
        borderTop: `1px solid ${DAANA.hairlineSoft}`, display: 'flex', alignItems: 'flex-start', justifyContent: 'space-around',
        padding: '10px 8px 0', zIndex: 5,
      }}>
        {[
          { i: 'home', l: 'Home', on: true },
          { i: 'grid', l: 'Categories' },
          { i: 'sparkle', l: 'Assistant' },
          { i: 'bag', l: 'Cart', badge: 4 },
        ].map((n, i) => (
          <button key={i} style={{
            background: 'transparent', border: 'none', display: 'flex', flexDirection: 'column',
            alignItems: 'center', gap: 4, color: n.on ? DAANA.ink : DAANA.ink50, position: 'relative',
          }}>
            <Icon name={n.i} size={20} color={n.on ? DAANA.ink : DAANA.ink50} />
            <span style={{ fontSize: 10.5 }}>{n.l}</span>
            {n.badge && (
              <span style={{
                position: 'absolute', top: -2, right: 8, fontSize: 9, background: DAANA.moss, color: DAANA.bg,
                width: 14, height: 14, borderRadius: 999, display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{n.badge}</span>
            )}
          </button>
        ))}
      </div>
    </div>
  );
}

// ── Mobile Voice screen ─────────────────────────────────────
function MobileVoice() {
  const [lang, setLang] = React.useState('ur');
  const [phase, setPhase] = React.useState('items');

  return (
    <div className="daana" style={{
      width: '100%', height: '100%', background: DAANA.bg, position: 'relative',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* Header */}
      <div style={{ padding: '60px 20px 12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button style={{ width: 36, height: 36, background: 'transparent', border: 'none' }}>
          <Icon name="close" size={20} />
        </button>
        <Eyebrow>Voice order</Eyebrow>
        <div style={{ width: 36 }} />
      </div>

      {/* Lang toggle */}
      <div style={{ padding: '8px 20px', display: 'flex', justifyContent: 'center' }}>
        <div style={{ display: 'flex', gap: 2, padding: 4, background: DAANA.ink08, borderRadius: 999 }}>
          {[
            { id: 'en', l: 'English' },
            { id: 'ur', l: 'اردو' },
          ].map(l => (
            <button key={l.id} onClick={() => setLang(l.id)} style={{
              height: 32, padding: '0 18px', borderRadius: 999, border: 'none',
              background: lang === l.id ? DAANA.ink : 'transparent', color: lang === l.id ? DAANA.bg : DAANA.ink, fontSize: 13,
            }}>{l.l}</button>
          ))}
        </div>
      </div>

      {/* Mic */}
      <div style={{ padding: '32px 20px 16px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
        <div style={{ position: 'relative', width: 120, height: 120, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{
            position: 'absolute', inset: 0, borderRadius: 999, background: DAANA.moss,
            animation: 'daana-pulse 1.4s ease-in-out infinite', opacity: 0.18,
          }} />
          <div style={{
            position: 'absolute', inset: 14, borderRadius: 999, background: DAANA.moss,
            animation: 'daana-pulse 1.6s ease-in-out infinite 0.3s', opacity: 0.25,
          }} />
          <div style={{
            width: 84, height: 84, borderRadius: 999, background: DAANA.moss,
            display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
          }}>
            <Icon name="mic" size={32} color={DAANA.bg} />
          </div>
        </div>
        <div style={{ display: 'flex', gap: 3, alignItems: 'center', height: 36 }}>
          {Array.from({ length: 24 }).map((_, i) => (
            <div key={i} style={{
              width: 3, height: 4 + (Math.sin(i * 0.5) + 1) * 12, background: DAANA.moss, borderRadius: 2,
              animation: `daana-wave 0.${4 + (i % 6)}s ease-in-out infinite`, opacity: 0.85,
            }} />
          ))}
        </div>
      </div>

      {/* Transcription */}
      <div style={{ padding: '0 20px 16px' }}>
        <div style={{ background: DAANA.card, borderRadius: 16, padding: 18, border: `1px solid ${DAANA.hairlineSoft}` }}>
          <Eyebrow style={{ fontSize: 9.5 }}>Heard</Eyebrow>
          <div className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 24, marginTop: 8, color: DAANA.ink, lineHeight: 1.7 }}>
            ایک کلو ٹماٹر، دو لیٹر دودھ اور آدھا کلو قیمہ۔
          </div>
          <div style={{ fontSize: 12, color: DAANA.ink50, marginTop: 8, lineHeight: 1.4 }}>
            <span style={{ fontStyle: 'italic' }}>"One kilo tomatoes, two litres milk and half a kilo qeema."</span>
          </div>
        </div>
      </div>

      {/* Matched items */}
      <div className="scroll" style={{ flex: 1, padding: '0 20px 16px', overflowY: 'auto' }}>
        <Eyebrow style={{ marginBottom: 10, fontSize: 9.5 }}>Matched · 3 items</Eyebrow>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { k: 'tomatoes', q: '1 kg' },
            { k: 'milk', q: '2 × 1 L' },
            { k: 'beefMince', q: '500 g' },
          ].map((it, i) => {
            const p = PRODUCTS[it.k];
            return (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: 10,
                background: DAANA.card, borderRadius: 12, border: `1px solid ${DAANA.hairlineSoft}`,
              }}>
                <div style={{ width: 44, height: 44 }}>
                  <ProductPlaceholder label="" tone={p.tone} radius={8} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14 }}>{p.name}</div>
                  <div style={{ fontSize: 11.5, color: DAANA.ink50 }}>{it.q} · Rs {p.price}</div>
                </div>
                <Icon name="check" size={18} color={DAANA.moss} />
              </div>
            );
          })}
        </div>
      </div>

      {/* CTA */}
      <div style={{ padding: '12px 20px 40px', display: 'flex', flexDirection: 'column', gap: 8, background: DAANA.bg, borderTop: `1px solid ${DAANA.hairlineSoft}` }}>
        <Btn variant="primary" size="lg" full iconRight="arrowR">Add 3 items to cart</Btn>
        <Btn variant="quiet" size="md" full>Keep listening</Btn>
      </div>
    </div>
  );
}

// ── Mobile AI Recipe screen ──────────────────────────────────
function MobileAIRecipe() {
  return (
    <div className="daana scroll" style={{
      width: '100%', height: '100%', background: DAANA.bg, overflowY: 'auto', paddingBottom: 100,
    }}>
      {/* Header */}
      <div style={{ padding: '60px 20px 16px', display: 'flex', alignItems: 'center', gap: 10 }}>
        <button style={{ width: 36, height: 36, background: 'transparent', border: 'none' }}>
          <Icon name="chevL" size={20} />
        </button>
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8 }}>
          <Icon name="sparkle" size={14} color={DAANA.moss} />
          <Eyebrow style={{ fontSize: 9.5 }}>Recipes from your fridge</Eyebrow>
        </div>
      </div>

      <div style={{ padding: '0 20px' }}>
        <h1 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 30, lineHeight: 1.05, margin: 0, letterSpacing: '-0.02em' }}>
          Three things you can cook tonight.
        </h1>
      </div>

      {/* Pantry */}
      <div style={{ padding: '20px' }}>
        <Eyebrow style={{ fontSize: 9.5, marginBottom: 10 }}>You have · 6 ingredients</Eyebrow>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {['chicken breast', 'tomato', 'onion', 'ginger', 'dahi', 'green chilies'].map((p, i) => (
            <span key={i} style={{
              padding: '6px 10px', background: DAANA.card, border: `1px solid ${DAANA.hairlineSoft}`,
              borderRadius: 999, fontSize: 12, color: DAANA.ink70,
            }}>{p}</span>
          ))}
          <span style={{
            padding: '6px 12px', background: DAANA.ink08, border: `1px dashed ${DAANA.hairline}`,
            borderRadius: 999, fontSize: 12, color: DAANA.ink70,
          }}>+ add</span>
        </div>
      </div>

      {/* Recipe cards */}
      <div style={{ padding: '0 20px 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {[
          { name: 'Chicken Karahi', urdu: 'کڑاہی', time: '35 m', match: 92, have: 5, need: 3, blurb: 'Bright, tomato-forward karahi finished with ginger.', tag: 'Best match' },
          { name: 'Murgh Cholay', urdu: 'مرغ چنے', time: '50 m', match: 84, have: 5, need: 2, blurb: 'Slow chickpea curry with shredded chicken.' },
          { name: 'Dahi Chicken', urdu: 'دہی مرغی', time: '25 m', match: 78, have: 5, need: 2, blurb: 'Yogurt-tenderized chicken, almost-sweet sauce.' },
        ].map((r, i) => (
          <div key={i} style={{
            background: i === 0 ? DAANA.ink : DAANA.card,
            color: i === 0 ? DAANA.bg : DAANA.ink,
            borderRadius: 18, padding: 16, border: `1px solid ${i === 0 ? DAANA.ink : DAANA.hairlineSoft}`,
            display: 'flex', gap: 14,
          }}>
            <div style={{ width: 80, height: 80, flexShrink: 0, borderRadius: 12, overflow: 'hidden' }}>
              <ProductPlaceholder label={r.name.toLowerCase().split(' ')[0]} tone="c" radius={12} />
            </div>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
                <div style={{ fontFamily: DAANA.mono, fontSize: 9.5, opacity: 0.6, letterSpacing: '0.12em' }}>
                  {r.tag || `${r.match}% MATCH`}
                </div>
                <div style={{ fontSize: 11, opacity: 0.6 }}>{r.time}</div>
              </div>
              <div className="serif" style={{ fontFamily: DAANA.serif, fontSize: 22, lineHeight: 1.05, letterSpacing: '-0.01em' }}>
                {r.name} <span className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 16, opacity: 0.6 }}>{r.urdu}</span>
              </div>
              <div style={{ fontSize: 12, opacity: 0.7, lineHeight: 1.4 }}>{r.blurb}</div>
              <div style={{
                marginTop: 6, fontSize: 11, opacity: 0.85, display: 'flex', gap: 10,
              }}>
                <span><Icon name="check" size={10} color={i === 0 ? DAANA.bg : DAANA.moss} /> {r.have} have</span>
                <span style={{ opacity: 0.6 }}>+ {r.need} to add</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { MobileHome, MobileVoice, MobileAIRecipe });
