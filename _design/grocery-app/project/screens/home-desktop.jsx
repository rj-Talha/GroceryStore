// Desktop Home — daana
// Top nav, hero, categories, recommendations, AI tile, voice tile

function HomeDesktop() {
  const [cat, setCat] = React.useState('all');
  const [voiceOpen, setVoiceOpen] = React.useState(false);

  const cats = [
    { id: 'all', label: 'All' },
    { id: 'fruits', label: 'Fruits' },
    { id: 'vegetables', label: 'Vegetables' },
    { id: 'meat', label: 'Meat & Poultry' },
    { id: 'dairy', label: 'Dairy & Eggs' },
    { id: 'pantry', label: 'Pantry' },
    { id: 'bakery', label: 'Bakery' },
  ];

  const recForYou = [
    { ...PRODUCTS.mangoesSindhri, reason: 'Peak of Sindhri season' },
    { ...PRODUCTS.chai, reason: 'You buy this every 3 weeks' },
    { ...PRODUCTS.basmati, reason: 'Running low — last bought 14 Apr' },
    { ...PRODUCTS.chickenBreast, reason: 'On offer · ends today' },
    { ...PRODUCTS.yogurt, reason: 'Pairs with your usual order' },
  ];

  return (
    <div className="daana" style={{ background: DAANA.bg, minHeight: '100%', position: 'relative' }}>
      <NavBar onVoice={() => setVoiceOpen(true)} />

      {/* Hero */}
      <div style={{ padding: '32px 56px 0', display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 24 }}>
        <HeroPanel onVoice={() => setVoiceOpen(true)} />
        <DeliverySlot />
      </div>

      {/* Categories */}
      <section style={{ padding: '48px 56px 0' }}>
        <SectionHead eyebrow="Shop by aisle" title="Categories" />
        <CategoryRow />
      </section>

      {/* Recommendations */}
      <section style={{ padding: '48px 56px 0' }}>
        <SectionHead
          eyebrow="For you · curated daily"
          title="Picked for your pantry"
          right={
            <div style={{ display: 'flex', gap: 8 }}>
              {cats.slice(0, 5).map(c => (
                <Chip key={c.id} active={cat === c.id} onClick={() => setCat(c.id)}>{c.label}</Chip>
              ))}
            </div>
          }
        />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 16 }}>
          {recForYou.map((p, i) => <RecCard key={i} p={p} />)}
        </div>
      </section>

      {/* AI duo */}
      <section style={{ padding: '64px 56px 0' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 24 }}>
          <AIRecipeTile />
          <AIIngredientTile />
        </div>
      </section>

      {/* Seasonal */}
      <section style={{ padding: '64px 56px 0' }}>
        <SectionHead eyebrow="In season · May" title="The mango list" />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16 }}>
          {[
            { ...PRODUCTS.mangoesSindhri, name: 'Sindhri', unit: '1 kg · sweet, fibrous', price: 320 },
            { ...PRODUCTS.mangoesSindhri, name: 'Chaunsa', unit: '1 kg · honeyed', price: 380, label: 'chaunsa' },
            { ...PRODUCTS.mangoesSindhri, name: 'Anwar Ratol', unit: '1 kg · floral', price: 460, label: 'ratol' },
            { ...PRODUCTS.mangoesSindhri, name: 'Langra', unit: '1 kg · tangy', price: 340, label: 'langra' },
          ].map((p, i) => <ProductCard key={i} p={p} onAdd={() => {}} />)}
        </div>
      </section>

      {/* Footer */}
      <Footer />

      {voiceOpen && <VoiceModal onClose={() => setVoiceOpen(false)} />}
    </div>
  );
}

// ── Nav ──────────────────────────────────────────────────────
function NavBar({ onVoice }) {
  return (
    <div style={{
      padding: '20px 56px', display: 'flex', alignItems: 'center', gap: 32,
      borderBottom: `1px solid ${DAANA.hairlineSoft}`, background: DAANA.bg,
      position: 'sticky', top: 0, zIndex: 10,
    }}>
      <DaanaWordmark size={26} sub="karachi" />
      <nav style={{ display: 'flex', gap: 24, fontSize: 14 }}>
        {['Shop', 'Recipes', 'Voice order', 'Subscribe'].map(l => (
          <a key={l} style={{ color: DAANA.ink70, textDecoration: 'none', cursor: 'pointer' }}>{l}</a>
        ))}
      </nav>
      {/* Search */}
      <div style={{
        flex: 1, maxWidth: 520, marginLeft: 'auto', height: 44, borderRadius: 999,
        border: `1px solid ${DAANA.hairline}`, background: DAANA.card,
        display: 'flex', alignItems: 'center', padding: '0 6px 0 18px', gap: 8,
      }}>
        <Icon name="search" size={16} color={DAANA.ink50} />
        <input
          placeholder="Search 'daal masoor' or try 'مرغی'"
          style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 14, color: DAANA.ink }}
        />
        <button onClick={onVoice} style={{
          width: 32, height: 32, borderRadius: 999, background: DAANA.ink08, border: 'none',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="mic" size={15} />
        </button>
      </div>
      <button style={{ background: 'transparent', border: 'none', display: 'flex', alignItems: 'center', gap: 6, fontSize: 13, color: DAANA.ink70 }}>
        <Icon name="globe" size={15} />
        EN · اردو
      </button>
      <button style={{
        background: 'transparent', border: `1px solid ${DAANA.hairline}`, height: 40, padding: '0 14px',
        borderRadius: 999, display: 'flex', alignItems: 'center', gap: 10, fontSize: 13,
      }}>
        <Icon name="bag" size={16} />
        Cart
        <span style={{ background: DAANA.ink, color: DAANA.bg, fontSize: 11, padding: '2px 7px', borderRadius: 999, fontVariantNumeric: 'tabular-nums' }}>4</span>
      </button>
    </div>
  );
}

function HeroPanel({ onVoice }) {
  return (
    <div style={{
      background: DAANA.ink, color: DAANA.bg, borderRadius: 24, padding: 40,
      position: 'relative', overflow: 'hidden', minHeight: 320,
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
    }}>
      {/* decorative grain */}
      <svg width="280" height="280" style={{ position: 'absolute', right: -40, top: -40, opacity: 0.08 }} viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="45" fill="none" stroke={DAANA.bg} strokeWidth="0.4" />
        <circle cx="50" cy="50" r="35" fill="none" stroke={DAANA.bg} strokeWidth="0.4" />
        <circle cx="50" cy="50" r="25" fill="none" stroke={DAANA.bg} strokeWidth="0.4" />
        <circle cx="50" cy="50" r="15" fill="none" stroke={DAANA.bg} strokeWidth="0.4" />
      </svg>

      <Eyebrow style={{ color: 'rgba(246,243,236,0.55)' }}>This week · 23 May</Eyebrow>

      <div>
        <h1 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 64, lineHeight: 1, margin: 0, letterSpacing: '-0.02em', maxWidth: 540 }}>
          Mangoes have <em style={{ color: '#C8B583', fontStyle: 'italic' }}>landed</em>.
        </h1>
        <p style={{ fontSize: 16, lineHeight: 1.5, color: 'rgba(246,243,236,0.75)', marginTop: 16, maxWidth: 480 }}>
          Five varietals from Mirpurkhas and Multan, picked this morning, on your kitchen counter by 8pm.
        </p>
      </div>

      <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
        <Btn variant="moss" size="lg" iconRight="arrowR">Shop the mango list</Btn>
        <button onClick={onVoice} style={{
          height: 48, padding: '0 22px', borderRadius: 999,
          background: 'rgba(246,243,236,0.08)', color: DAANA.bg, border: `1px solid rgba(246,243,236,0.18)`,
          display: 'inline-flex', alignItems: 'center', gap: 10, fontSize: 15,
        }}>
          <Icon name="mic" size={16} />
          Order by voice
        </button>
      </div>
    </div>
  );
}

function DeliverySlot() {
  return (
    <div style={{ background: DAANA.card, borderRadius: 24, padding: 28, border: `1px solid ${DAANA.hairlineSoft}`, display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <Icon name="pin" size={16} color={DAANA.moss} />
        <Eyebrow>Deliver to</Eyebrow>
      </div>
      <div className="serif" style={{ fontFamily: DAANA.serif, fontSize: 26, lineHeight: 1.1, letterSpacing: '-0.01em' }}>
        Khayaban-e-Bukhari,<br/>DHA Phase VI, Karachi
      </div>
      <Hr />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        <SlotRow time="Today, 6 – 8 pm" tag="Recommended" cost="Free" selected />
        <SlotRow time="Today, 8 – 10 pm" cost="Free" />
        <SlotRow time="Tomorrow, 7 – 9 am" cost="Rs 99 · early" />
      </div>
      <button style={{
        background: 'transparent', border: 'none', textAlign: 'left', padding: 0, fontSize: 13, color: DAANA.moss,
        display: 'flex', alignItems: 'center', gap: 6,
      }}>
        Change address <Icon name="chevR" size={13} />
      </button>
    </div>
  );
}

function SlotRow({ time, tag, cost, selected }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0',
    }}>
      <div style={{
        width: 16, height: 16, borderRadius: 999, border: `1.5px solid ${selected ? DAANA.moss : DAANA.hairline}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        {selected && <div style={{ width: 7, height: 7, borderRadius: 999, background: DAANA.moss }} />}
      </div>
      <div style={{ flex: 1, fontSize: 14 }}>{time}</div>
      {tag && <div style={{ fontFamily: DAANA.mono, fontSize: 10, color: DAANA.moss, letterSpacing: '0.1em', textTransform: 'uppercase' }}>{tag}</div>}
      <div style={{ fontSize: 13, color: DAANA.ink70 }}>{cost}</div>
    </div>
  );
}

function SectionHead({ eyebrow, title, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 20, gap: 24 }}>
      <div>
        <Eyebrow>{eyebrow}</Eyebrow>
        <h2 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 38, lineHeight: 1, letterSpacing: '-0.02em', margin: '8px 0 0' }}>
          {title}
        </h2>
      </div>
      {right}
    </div>
  );
}

function CategoryRow() {
  const items = [
    { id: 'fruits', label: 'Fruits', urdu: 'پھل', tone: 'c', count: 84 },
    { id: 'veg', label: 'Vegetables', urdu: 'سبزی', tone: 'b', count: 132 },
    { id: 'meat', label: 'Meat & Poultry', urdu: 'گوشت', tone: 'a', count: 46 },
    { id: 'dairy', label: 'Dairy & Eggs', urdu: 'دودھ', tone: 'd', count: 58 },
    { id: 'bakery', label: 'Bakery', urdu: 'بیکری', tone: 'c', count: 37 },
    { id: 'pantry', label: 'Pantry', urdu: 'راشن', tone: 'd', count: 240 },
    { id: 'drinks', label: 'Drinks', urdu: 'مشروبات', tone: 'b', count: 91 },
    { id: 'household', label: 'Household', urdu: 'گھر', tone: 'e', count: 64 },
  ];
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 12 }}>
      {items.map(c => (
        <button key={c.id} style={{
          background: DAANA.card, border: `1px solid ${DAANA.hairlineSoft}`, borderRadius: 16,
          padding: 14, display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 10,
          minHeight: 132, textAlign: 'left',
        }}>
          <div style={{ width: 56, height: 56 }}>
            <ProductPlaceholder label="" tone={c.tone} radius={10} />
          </div>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
            <div style={{ fontSize: 13, lineHeight: 1.2 }}>{c.label}</div>
            <div className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 14, color: DAANA.ink50, lineHeight: 1 }}>{c.urdu}</div>
          </div>
          <div style={{ fontFamily: DAANA.mono, fontSize: 10, color: DAANA.ink30 }}>{c.count} items</div>
        </button>
      ))}
    </div>
  );
}

function RecCard({ p }) {
  return (
    <div style={{
      background: DAANA.card, borderRadius: 16, padding: 14, border: `1px solid ${DAANA.hairlineSoft}`,
      display: 'flex', flexDirection: 'column', gap: 10,
    }}>
      <div style={{ position: 'relative' }}>
        <ProductPlaceholder label={p.label} tone={p.tone} radius={12} />
        {p.deal && (
          <div style={{
            position: 'absolute', top: 8, left: 8, fontFamily: DAANA.mono, fontSize: 9,
            background: DAANA.ink, color: DAANA.bg, padding: '3px 6px', borderRadius: 4, letterSpacing: '0.1em',
          }}>−{p.deal}%</div>
        )}
        <button style={{
          position: 'absolute', bottom: 8, right: 8, width: 30, height: 30, borderRadius: 999,
          background: DAANA.ink, color: DAANA.bg, border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="plus" size={14} color={DAANA.bg} />
        </button>
      </div>
      <div>
        <div style={{ fontSize: 14, lineHeight: 1.25 }}>{p.name}</div>
        <div style={{ fontSize: 11.5, color: DAANA.ink50 }}>{p.unit}</div>
      </div>
      <div style={{
        fontSize: 11.5, color: DAANA.moss, lineHeight: 1.3, paddingTop: 8, borderTop: `1px dashed ${DAANA.hairlineSoft}`,
        display: 'flex', alignItems: 'flex-start', gap: 6,
      }}>
        <Icon name="sparkle" size={11} color={DAANA.moss} />
        <span style={{ flex: 1 }}>{p.reason}</span>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
        <Price value={p.price} size={15} />
        {p.old && <span style={{ fontSize: 11, color: DAANA.ink30, textDecoration: 'line-through', fontVariantNumeric: 'tabular-nums' }}>Rs {p.old.toLocaleString('en-PK')}</span>}
      </div>
    </div>
  );
}

function AIRecipeTile() {
  return (
    <div style={{
      background: '#283D26', color: '#F6F3EC', borderRadius: 24, padding: 32,
      minHeight: 240, display: 'flex', flexDirection: 'column', justifyContent: 'space-between', position: 'relative', overflow: 'hidden',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <Icon name="sparkle" size={14} color="rgba(246,243,236,0.7)" />
        <Eyebrow style={{ color: 'rgba(246,243,236,0.55)' }}>Assistant · Recipes</Eyebrow>
      </div>
      <h3 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 36, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, maxWidth: 380 }}>
        What's in your fridge tonight?
      </h3>
      <p style={{ fontSize: 14, color: 'rgba(246,243,236,0.7)', maxWidth: 360, margin: 0 }}>
        Tell us what you have. We'll suggest three things you can cook in under an hour — in English or Urdu.
      </p>
      <div style={{
        background: 'rgba(246,243,236,0.08)', border: '1px solid rgba(246,243,236,0.15)',
        borderRadius: 12, padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <span style={{ fontFamily: DAANA.mono, fontSize: 11, color: 'rgba(246,243,236,0.55)' }}>›</span>
        <span style={{ fontSize: 14, color: 'rgba(246,243,236,0.85)', flex: 1 }}>chicken, tomato, ginger, onions, dahi…</span>
        <Btn variant="moss" size="sm" style={{ background: '#F6F3EC', color: DAANA.ink }}>Suggest</Btn>
      </div>
    </div>
  );
}

function AIIngredientTile() {
  return (
    <div style={{
      background: DAANA.card, borderRadius: 24, padding: 32,
      minHeight: 240, display: 'flex', flexDirection: 'column', justifyContent: 'space-between', border: `1px solid ${DAANA.hairlineSoft}`,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <Icon name="book" size={14} color={DAANA.moss} />
        <Eyebrow>Assistant · Ingredients</Eyebrow>
      </div>
      <h3 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 36, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, maxWidth: 380 }}>
        Tell us the dish.<br/>We'll fill the basket.
      </h3>
      <p style={{ fontSize: 14, color: DAANA.ink70, maxWidth: 360, margin: 0 }}>
        "Chicken karahi for 4." Daana matches every ingredient to a product, adjusts for serving size, and adds it to your cart.
      </p>
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        {['Chicken karahi', 'Aloo gosht', 'Daal chawal', 'Pasta arrabiata'].map((s, i) => (
          <button key={i} style={{
            height: 34, padding: '0 14px', borderRadius: 999, background: DAANA.bg,
            border: `1px solid ${DAANA.hairline}`, fontSize: 13, color: DAANA.ink70,
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            {s}
          </button>
        ))}
      </div>
    </div>
  );
}

function Footer() {
  return (
    <footer style={{ padding: '96px 56px 48px', display: 'grid', gridTemplateColumns: '1.5fr 1fr 1fr 1fr', gap: 40 }}>
      <div>
        <DaanaWordmark size={28} />
        <p style={{ fontSize: 14, color: DAANA.ink70, lineHeight: 1.5, maxWidth: 280, marginTop: 12 }}>
          A quieter grocery, built for Pakistani kitchens. Delivered in 90 minutes across DHA, Clifton, and Gulberg.
        </p>
      </div>
      {[
        { h: 'Shop', l: ['Fresh produce', 'Pantry essentials', 'Meat & poultry', 'Subscriptions'] },
        { h: 'Helpers', l: ['Recipe assistant', 'Ingredient finder', 'Voice order', 'Refer a friend'] },
        { h: 'Company', l: ['About daana', 'Sourcing', 'Careers', 'Press'] },
      ].map(c => (
        <div key={c.h}>
          <Eyebrow>{c.h}</Eyebrow>
          <ul style={{ listStyle: 'none', padding: 0, margin: '14px 0 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
            {c.l.map(i => <li key={i} style={{ fontSize: 14, color: DAANA.ink70 }}>{i}</li>)}
          </ul>
        </div>
      ))}
    </footer>
  );
}

// Voice modal — used across home/cart
function VoiceModal({ onClose, lang: initialLang = 'ur' }) {
  const [lang, setLang] = React.useState(initialLang);
  const [phase, setPhase] = React.useState('listen'); // listen | transcribed | items
  const [tIdx, setTIdx] = React.useState(0);

  const scripts = {
    ur: [
      { said: 'ایک کلو ٹماٹر', en: 'one kilo tomatoes', match: 'tomatoes', qty: '1 kg' },
      { said: 'دو لیٹر دودھ', en: 'two litres milk', match: 'milk', qty: '2 L' },
      { said: 'آدھا کلو قیمہ', en: 'half kilo qeema', match: 'beefMince', qty: '500 g' },
    ],
    en: [
      { said: 'a dozen eggs', en: 'a dozen eggs', match: 'eggs', qty: '12 pcs' },
      { said: 'two kilos basmati rice', en: 'two kilos basmati', match: 'basmati', qty: '2 × 5 kg' },
      { said: 'half kilo chicken breast', en: 'chicken breast', match: 'chickenBreast', qty: '500 g' },
    ],
  };

  React.useEffect(() => {
    if (phase !== 'listen') return;
    const t = setTimeout(() => setPhase('transcribed'), 1600);
    return () => clearTimeout(t);
  }, [phase]);
  React.useEffect(() => {
    if (phase !== 'transcribed') return;
    const t = setTimeout(() => setPhase('items'), 1100);
    return () => clearTimeout(t);
  }, [phase]);

  const items = scripts[lang];

  return (
    <div style={{
      position: 'absolute', inset: 0, background: 'rgba(26,24,20,0.45)',
      backdropFilter: 'blur(8px)', zIndex: 100, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 40,
    }} onClick={onClose}>
      <div onClick={e => e.stopPropagation()} style={{
        width: 560, background: DAANA.bg, borderRadius: 24, padding: 36, position: 'relative',
        animation: 'daana-fade-up .3s ease-out',
      }}>
        <button onClick={onClose} style={{
          position: 'absolute', top: 16, right: 16, width: 32, height: 32, borderRadius: 999,
          background: 'transparent', border: 'none',
        }}>
          <Icon name="close" size={16} />
        </button>
        {/* Lang toggle */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24 }}>
          <Eyebrow>Voice order · beta</Eyebrow>
          <div style={{ display: 'flex', gap: 4, padding: 4, background: DAANA.ink08, borderRadius: 999 }}>
            {['en', 'ur'].map(l => (
              <button key={l} onClick={() => { setLang(l); setPhase('listen'); }} style={{
                height: 28, padding: '0 14px', borderRadius: 999, border: 'none',
                background: lang === l ? DAANA.ink : 'transparent', color: lang === l ? DAANA.bg : DAANA.ink, fontSize: 12,
              }}>{l === 'en' ? 'English' : 'اردو'}</button>
            ))}
          </div>
        </div>

        {/* Mic visual */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16, padding: '8px 0 24px' }}>
          <div style={{ position: 'relative', width: 96, height: 96, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{
              position: 'absolute', inset: 0, borderRadius: 999, background: DAANA.moss,
              animation: phase === 'listen' ? 'daana-pulse 1.4s ease-in-out infinite' : 'none', opacity: 0.18,
            }} />
            <div style={{
              width: 72, height: 72, borderRadius: 999, background: DAANA.moss,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon name="mic" size={28} color={DAANA.bg} />
            </div>
          </div>
          {/* Waveform */}
          <div style={{ display: 'flex', gap: 3, alignItems: 'center', height: 36 }}>
            {Array.from({ length: 32 }).map((_, i) => (
              <div key={i} style={{
                width: 3, height: 4 + (Math.sin(i * 0.7) + 1) * 14, background: DAANA.moss, borderRadius: 2,
                animation: phase === 'listen' ? `daana-wave 0.${4 + (i % 6)}s ease-in-out infinite` : 'none',
                opacity: phase === 'listen' ? 0.85 : 0.3,
              }} />
            ))}
          </div>
          <div style={{ fontSize: 13, color: DAANA.ink50 }}>
            {phase === 'listen' ? (lang === 'ur' ? 'سن رہا ہوں…' : 'Listening…') : 'Got it.'}
          </div>
        </div>

        {/* Transcription */}
        <div style={{ background: DAANA.card, borderRadius: 16, padding: 20, minHeight: 100, border: `1px solid ${DAANA.hairlineSoft}` }}>
          {phase === 'listen' ? (
            <div style={{ fontSize: 14, color: DAANA.ink30 }}>
              {lang === 'ur'
                ? 'مثال کے طور پر کہیں: "ایک کلو ٹماٹر اور دودھ"'
                : 'Try saying: "Add half kilo qeema and a dozen eggs"'}
            </div>
          ) : (
            <div>
              <Eyebrow style={{ fontSize: 9 }}>Heard</Eyebrow>
              {lang === 'ur' ? (
                <div className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 26, marginTop: 8, color: DAANA.ink, lineHeight: 1.6 }}>
                  ایک کلو ٹماٹر، دو لیٹر دودھ اور آدھا کلو قیمہ۔
                </div>
              ) : (
                <div style={{ fontSize: 18, marginTop: 8 }}>
                  A dozen eggs, two kilos basmati and half a kilo of chicken breast.
                </div>
              )}
              <div style={{ fontSize: 12, color: DAANA.ink50, marginTop: 8 }}>
                {lang === 'ur' ? 'Translated: ' : ''}
                <span style={{ fontStyle: 'italic' }}>{items.map(i => i.en).join(', ')}.</span>
              </div>
            </div>
          )}
        </div>

        {/* Matched items */}
        {phase === 'items' && (
          <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {items.map((it, i) => {
              const p = PRODUCTS[it.match];
              return (
                <div key={i} style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: 10,
                  background: DAANA.card, borderRadius: 12, border: `1px solid ${DAANA.hairlineSoft}`,
                  animation: `daana-fade-up .3s ease-out ${i * 0.08}s both`,
                }}>
                  <div style={{ width: 40, height: 40 }}>
                    <ProductPlaceholder label="" tone={p.tone} radius={8} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 14 }}>{p.name}</div>
                    <div style={{ fontSize: 11.5, color: DAANA.ink50 }}>{it.qty} · {p.unit}</div>
                  </div>
                  <Icon name="check" size={16} color={DAANA.moss} />
                </div>
              );
            })}
            <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
              <Btn variant="quiet" size="md">Keep listening</Btn>
              <Btn variant="primary" size="md" full iconRight="arrowR">Add 3 items to cart</Btn>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { HomeDesktop, NavBar, VoiceModal, SectionHead });
