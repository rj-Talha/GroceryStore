// Daana — shared design tokens & primitives
// Premium minimal grocery, bilingual EN/UR

const DAANA = {
  // Warm cream paper
  bg: '#F6F3EC',
  bgAlt: '#EFEBE0',
  card: '#FBF9F3',
  // Deep warm ink
  ink: '#1A1814',
  ink70: 'rgba(26,24,20,0.7)',
  ink50: 'rgba(26,24,20,0.5)',
  ink30: 'rgba(26,24,20,0.3)',
  ink15: 'rgba(26,24,20,0.15)',
  ink08: 'rgba(26,24,20,0.08)',
  // Deep moss — single accent
  moss: '#3D5A3A',
  mossInk: '#283D26',
  // Accent helpers
  saffron: '#B8703A',  // for "deal" / discount badges sparingly
  // Surfaces
  hairline: 'rgba(26,24,20,0.12)',
  hairlineSoft: 'rgba(26,24,20,0.06)',
  // Type
  serif: '"Instrument Serif", "Cormorant Garamond", Georgia, serif',
  sans: '"Geist", "Söhne", -apple-system, "Helvetica Neue", Arial, sans-serif',
  mono: '"Geist Mono", "JetBrains Mono", ui-monospace, monospace',
  urdu: '"Noto Nastaliq Urdu", "Jameel Noori Nastaleeq", serif',
};

// One-time global CSS (resets within Daana surfaces only)
if (typeof document !== 'undefined' && !document.getElementById('daana-base')) {
  const s = document.createElement('style');
  s.id = 'daana-base';
  s.textContent = `
    .daana, .daana * { box-sizing: border-box; }
    .daana { font-family: ${DAANA.sans}; color: ${DAANA.ink}; -webkit-font-smoothing: antialiased; font-feature-settings: 'ss01','cv11'; }
    .daana button { font-family: inherit; cursor: pointer; }
    .daana input, .daana textarea { font-family: inherit; }
    .daana .serif { font-family: ${DAANA.serif}; font-weight: 400; letter-spacing: -0.01em; }
    .daana .mono { font-family: ${DAANA.mono}; }
    .daana .urdu { font-family: ${DAANA.urdu}; direction: rtl; line-height: 1.9; }
    .daana ::selection { background: ${DAANA.moss}; color: ${DAANA.bg}; }
    .daana .scroll::-webkit-scrollbar { display: none; }
    .daana .scroll { scrollbar-width: none; }
    @keyframes daana-pulse { 0%, 100% { opacity: .35; transform: scale(1); } 50% { opacity: 1; transform: scale(1.06); } }
    @keyframes daana-wave { 0% { transform: scaleY(0.3); } 50% { transform: scaleY(1); } 100% { transform: scaleY(0.3); } }
    @keyframes daana-shine { 0% { background-position: -200% 0; } 100% { background-position: 200% 0; } }
    @keyframes daana-fade-up { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes daana-spin { to { transform: rotate(360deg); } }
  `;
  document.head.appendChild(s);
}

// ── Wordmark ─────────────────────────────────────────────────
function DaanaMark({ size = 16, color = DAANA.ink }) {
  // small seed/grain glyph
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ display: 'block' }}>
      <path d="M12 3C7 3 4 7 4 12s3 9 8 9c2 0 4-1 5-3-3-1-5-3-5-6s2-5 5-6c-1-2-3-3-5-3z" fill={color}/>
      <circle cx="15.5" cy="12" r="1.2" fill={DAANA.bg}/>
    </svg>
  );
}

function DaanaWordmark({ size = 28, color = DAANA.ink, sub }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
      <span className="serif" style={{ fontFamily: DAANA.serif, fontSize: size, color, letterSpacing: '-0.02em', lineHeight: 1 }}>
        daana<span style={{ color: DAANA.moss }}>.</span>
      </span>
      {sub && <span style={{ fontSize: size * 0.32, color: DAANA.ink50, letterSpacing: '0.18em', textTransform: 'uppercase' }}>{sub}</span>}
    </div>
  );
}

// ── Product placeholder (no AI-drawn produce) ────────────────
// Subtly striped SVG placeholder with monospace label.
function ProductPlaceholder({ label = 'product', tone = 'a', square = true, radius = 12 }) {
  const tones = {
    a: { bg: '#E8E2D2', stripe: '#D9D0BC', ink: 'rgba(26,24,20,0.55)' },
    b: { bg: '#DDE2D5', stripe: '#CBD3C0', ink: 'rgba(40,61,38,0.7)' },
    c: { bg: '#EBDFD0', stripe: '#DECBB4', ink: 'rgba(120,75,30,0.7)' },
    d: { bg: '#E0DED7', stripe: '#CFCCC2', ink: 'rgba(26,24,20,0.55)' },
    e: { bg: '#D8DBD3', stripe: '#C5C9BD', ink: 'rgba(26,24,20,0.6)' },
  };
  const t = tones[tone] || tones.a;
  const id = `stripe-${tone}-${label.replace(/\W/g, '')}`;
  return (
    <div style={{
      width: '100%', aspectRatio: square ? '1 / 1' : '4 / 5',
      borderRadius: radius, background: t.bg, position: 'relative', overflow: 'hidden',
    }}>
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
        <defs>
          <pattern id={id} width="14" height="14" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
            <line x1="0" y1="0" x2="0" y2="14" stroke={t.stripe} strokeWidth="6" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill={`url(#${id})`} opacity="0.55" />
      </svg>
      <div style={{
        position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontFamily: DAANA.mono, fontSize: 10, color: t.ink, letterSpacing: '0.1em', textTransform: 'uppercase',
      }}>{label}</div>
    </div>
  );
}

// ── Hairline divider ─────────────────────────────────────────
function Hr({ vertical, color = DAANA.hairline, style = {} }) {
  return <div style={{ background: color, ...(vertical ? { width: 1, alignSelf: 'stretch' } : { height: 1, width: '100%' }), ...style }} />;
}

// ── Icon set (line, 1.5px) ───────────────────────────────────
const Icon = ({ name, size = 18, color = 'currentColor', stroke = 1.5 }) => {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const paths = {
    search: <><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></>,
    mic: <><rect x="9" y="3" width="6" height="12" rx="3" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></>,
    cart: <><path d="M3 4h2l2.6 12.3a2 2 0 0 0 2 1.7h7.8a2 2 0 0 0 2-1.6L21 8H6" /><circle cx="10" cy="21" r="1.2" /><circle cx="18" cy="21" r="1.2" /></>,
    bag: <><path d="M5 8h14l-1 12a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 8z" /><path d="M9 8V6a3 3 0 0 1 6 0v2" /></>,
    user: <><circle cx="12" cy="8" r="4" /><path d="M4 21a8 8 0 0 1 16 0" /></>,
    heart: <><path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z" /></>,
    plus: <><path d="M12 5v14M5 12h14" /></>,
    minus: <><path d="M5 12h14" /></>,
    chevR: <><path d="m9 6 6 6-6 6" /></>,
    chevL: <><path d="m15 6-6 6 6 6" /></>,
    chevD: <><path d="m6 9 6 6 6-6" /></>,
    arrowR: <><path d="M5 12h14m-5-6 6 6-6 6" /></>,
    arrowUp: <><path d="M12 5v14m-7-7 7-7 7 7" /></>,
    close: <><path d="M6 6l12 12M18 6 6 18" /></>,
    sparkle: <><path d="M12 3v6m0 6v6M3 12h6m6 0h6" /><path d="M5.6 5.6 9 9m6 6 3.4 3.4M5.6 18.4 9 15m6-6 3.4-3.4" opacity=".5" /></>,
    leaf: <><path d="M5 19c0-9 7-14 14-14 0 9-5 14-14 14z" /><path d="M5 19c4-4 8-7 11-9" /></>,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
    pin: <><path d="M12 21s7-7 7-12a7 7 0 1 0-14 0c0 5 7 12 7 12z" /><circle cx="12" cy="9" r="2.5" /></>,
    filter: <><path d="M4 6h16M7 12h10m-7 6h4" /></>,
    grid: <><rect x="4" y="4" width="7" height="7" rx="1" /><rect x="13" y="4" width="7" height="7" rx="1" /><rect x="4" y="13" width="7" height="7" rx="1" /><rect x="13" y="13" width="7" height="7" rx="1" /></>,
    home: <><path d="M4 11 12 4l8 7v9a1 1 0 0 1-1 1h-4v-6h-6v6H5a1 1 0 0 1-1-1v-9z" /></>,
    chef: <><path d="M7 14a5 5 0 1 1 10 0v6H7v-6z" /><path d="M9 14V9a3 3 0 0 1 6 0v5" /></>,
    book: <><path d="M4 5a2 2 0 0 1 2-2h12v18H6a2 2 0 0 1-2-2V5z" /><path d="M4 19a2 2 0 0 1 2-2h12" /></>,
    truck: <><path d="M3 7h11v9H3z" /><path d="M14 10h4l3 3v3h-7" /><circle cx="7" cy="18" r="2" /><circle cx="17" cy="18" r="2" /></>,
    check: <><path d="m5 12 5 5L20 7" /></>,
    info: <><circle cx="12" cy="12" r="9" /><path d="M12 8v.01M12 11v6" /></>,
    star: <><path d="m12 3 2.6 5.5 6 .8-4.4 4.2 1.1 6L12 16.8 6.7 19.5l1.1-6L3.4 9.3l6-.8L12 3z" /></>,
    flame: <><path d="M12 3c0 4-5 5-5 10a5 5 0 0 0 10 0c0-3-2-4-3-6 0 2-1 3-2 3 0-3 0-5 0-7z" /></>,
    settings: <><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z" /></>,
    waves: <><path d="M3 12c2-3 4-3 6 0s4 3 6 0 4-3 6 0" /><path d="M3 6c2-3 4-3 6 0s4 3 6 0 4-3 6 0" opacity=".5" /><path d="M3 18c2-3 4-3 6 0s4 3 6 0 4-3 6 0" opacity=".5" /></>,
    globe: <><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18" /></>,
  };
  return <svg {...p}>{paths[name]}</svg>;
};

// ── Button ───────────────────────────────────────────────────
function Btn({ children, variant = 'primary', size = 'md', icon, iconRight, full, onClick, style = {}, disabled }) {
  const sizes = {
    sm: { h: 32, px: 12, fs: 13 },
    md: { h: 40, px: 16, fs: 14 },
    lg: { h: 48, px: 22, fs: 15 },
  }[size];
  const variants = {
    primary: { bg: DAANA.ink, color: DAANA.bg, border: 'none' },
    moss:    { bg: DAANA.moss, color: '#F6F3EC', border: 'none' },
    ghost:   { bg: 'transparent', color: DAANA.ink, border: `1px solid ${DAANA.hairline}` },
    quiet:   { bg: 'transparent', color: DAANA.ink, border: 'none' },
    soft:    { bg: DAANA.ink08, color: DAANA.ink, border: 'none' },
  }[variant];
  return (
    <button onClick={onClick} disabled={disabled} style={{
      height: sizes.h, padding: `0 ${sizes.px}px`, fontSize: sizes.fs, letterSpacing: '-0.005em',
      borderRadius: 999, background: variants.bg, color: variants.color, border: variants.border,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      width: full ? '100%' : 'auto', fontWeight: 500, whiteSpace: 'nowrap',
      transition: 'transform .12s, opacity .12s', opacity: disabled ? 0.4 : 1,
      ...style,
    }}>
      {icon && <Icon name={icon} size={sizes.fs + 2} />}
      {children}
      {iconRight && <Icon name={iconRight} size={sizes.fs + 2} />}
    </button>
  );
}

// ── Chip ─────────────────────────────────────────────────────
function Chip({ children, active, onClick, icon }) {
  return (
    <button onClick={onClick} style={{
      height: 34, padding: '0 14px', borderRadius: 999,
      background: active ? DAANA.ink : 'transparent',
      color: active ? DAANA.bg : DAANA.ink,
      border: `1px solid ${active ? DAANA.ink : DAANA.hairline}`,
      fontSize: 13, fontWeight: 500, letterSpacing: '-0.005em',
      display: 'inline-flex', alignItems: 'center', gap: 6, whiteSpace: 'nowrap',
    }}>
      {icon && <Icon name={icon} size={14} />}
      {children}
    </button>
  );
}

// ── Price ────────────────────────────────────────────────────
function Price({ value, size = 16, color = DAANA.ink, currency = 'Rs' }) {
  return (
    <span style={{ fontSize: size, color, letterSpacing: '-0.01em', fontVariantNumeric: 'tabular-nums' }}>
      <span style={{ fontSize: size * 0.7, color: DAANA.ink50, marginRight: 3 }}>{currency}</span>
      {value.toLocaleString('en-PK')}
    </span>
  );
}

// ── Section label (small, mono-flavor) ───────────────────────
function Eyebrow({ children, style = {} }) {
  return <div style={{ fontFamily: DAANA.mono, fontSize: 10.5, letterSpacing: '0.18em', textTransform: 'uppercase', color: DAANA.ink50, ...style }}>{children}</div>;
}

// ── Product card (used across screens) ───────────────────────
function ProductCard({ p, compact, onAdd }) {
  return (
    <div className="daana" style={{
      background: DAANA.card, borderRadius: 16, padding: compact ? 12 : 14,
      border: `1px solid ${DAANA.hairlineSoft}`, display: 'flex', flexDirection: 'column', gap: compact ? 8 : 10,
      position: 'relative',
    }}>
      <div style={{ position: 'relative' }}>
        <ProductPlaceholder label={p.label} tone={p.tone || 'a'} radius={12} />
        {p.deal && (
          <div style={{
            position: 'absolute', top: 8, left: 8, fontFamily: DAANA.mono, fontSize: 9,
            background: DAANA.ink, color: DAANA.bg, padding: '3px 6px', borderRadius: 4, letterSpacing: '0.1em',
          }}>−{p.deal}%</div>
        )}
        {onAdd && (
          <button onClick={onAdd} style={{
            position: 'absolute', bottom: 8, right: 8, width: 30, height: 30, borderRadius: 999,
            background: DAANA.ink, color: DAANA.bg, border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="plus" size={14} color={DAANA.bg} />
          </button>
        )}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <div style={{ fontSize: compact ? 13 : 14, color: DAANA.ink, lineHeight: 1.25 }}>{p.name}</div>
        <div style={{ fontSize: 11.5, color: DAANA.ink50 }}>{p.unit}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginTop: 'auto' }}>
        <Price value={p.price} size={compact ? 14 : 15} />
        {p.old && <span style={{ fontSize: 11, color: DAANA.ink30, textDecoration: 'line-through', fontVariantNumeric: 'tabular-nums' }}>Rs {p.old.toLocaleString('en-PK')}</span>}
      </div>
    </div>
  );
}

// ── Sample product catalog (used across screens) ─────────────
const PRODUCTS = {
  mangoesSindhri: { name: 'Sindhri Mango', unit: '1 kg · seasonal', price: 320, label: 'mango', tone: 'c' },
  bananas:        { name: 'Banana, ripe', unit: '6 pcs · ~750 g', price: 180, label: 'banana', tone: 'c' },
  tomatoes:       { name: 'Tomato, vine', unit: '500 g', price: 95, label: 'tomato', tone: 'b' },
  onions:         { name: 'Onion, red', unit: '1 kg', price: 130, label: 'onion', tone: 'd' },
  potatoes:       { name: 'Potato, washed', unit: '1 kg', price: 110, label: 'potato', tone: 'd' },
  spinach:        { name: 'Palak (spinach)', unit: '1 bunch · 250 g', price: 80, label: 'palak', tone: 'b' },
  coriander:      { name: 'Hara Dhania', unit: '100 g', price: 30, label: 'dhania', tone: 'b' },
  ginger:         { name: 'Ginger', unit: '250 g', price: 145, label: 'adrak', tone: 'd' },
  garlic:         { name: 'Garlic, peeled', unit: '200 g', price: 220, label: 'lehsan', tone: 'd' },
  chickenBreast:  { name: 'Chicken Breast', unit: '500 g · zabiha', price: 720, old: 820, deal: 12, label: 'chicken', tone: 'a' },
  beefMince:      { name: 'Beef Qeema, lean', unit: '500 g', price: 990, label: 'qeema', tone: 'a' },
  eggs:           { name: 'Eggs, brown', unit: 'dozen', price: 360, label: 'eggs', tone: 'd' },
  milk:           { name: 'Olper\u2019s Milk', unit: '1 L · UHT', price: 290, label: 'milk', tone: 'd' },
  yogurt:         { name: 'Dahi, fresh', unit: '500 g', price: 210, label: 'dahi', tone: 'd' },
  butter:         { name: 'Salted Butter', unit: '227 g', price: 540, label: 'makhan', tone: 'c' },
  basmati:        { name: 'Basmati Rice, aged', unit: '5 kg · super kernel', price: 2150, label: 'basmati', tone: 'c' },
  atta:           { name: 'Chakki Atta', unit: '10 kg', price: 1480, label: 'atta', tone: 'c' },
  lentils:        { name: 'Daal Masoor', unit: '1 kg', price: 480, label: 'masoor', tone: 'c' },
  chickpeas:      { name: 'Kabuli Chana', unit: '1 kg', price: 520, label: 'chana', tone: 'c' },
  oil:            { name: 'Sunflower Oil', unit: '3 L tin', price: 1690, label: 'oil', tone: 'b' },
  chai:           { name: 'Tapal Danedar', unit: '430 g', price: 1090, label: 'chai', tone: 'a' },
  sugar:          { name: 'White Sugar', unit: '1 kg', price: 145, label: 'cheeni', tone: 'd' },
  bread:          { name: 'Sourdough Boule', unit: '500 g · daily', price: 420, label: 'bread', tone: 'c' },
  naan:           { name: 'Naan, tandoori', unit: '4 pcs', price: 160, label: 'naan', tone: 'c' },
  oranges:        { name: 'Kinnow Orange', unit: '1 kg', price: 240, label: 'kinnow', tone: 'c' },
  apples:         { name: 'Kala Kulu Apple', unit: '1 kg', price: 380, label: 'apple', tone: 'c' },
  paneer:         { name: 'Paneer, fresh', unit: '200 g', price: 320, label: 'paneer', tone: 'd' },
  greenChili:     { name: 'Hari Mirch', unit: '100 g', price: 25, label: 'mirch', tone: 'b' },
};

Object.assign(window, {
  DAANA, DaanaMark, DaanaWordmark, ProductPlaceholder, Hr, Icon,
  Btn, Chip, Price, Eyebrow, ProductCard, PRODUCTS,
});
