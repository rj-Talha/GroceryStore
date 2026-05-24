// Desktop Product Detail — daana

function ProductDetail() {
  const [qty, setQty] = React.useState(1);
  const [variant, setVariant] = React.useState('1kg');

  return (
    <div className="daana" style={{ background: DAANA.bg, minHeight: '100%' }}>
      <NavBar />
      <div style={{ padding: '24px 56px 0', display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: DAANA.ink50 }}>
        <span>Shop</span><Icon name="chevR" size={12} color={DAANA.ink30} />
        <span>Fruits</span><Icon name="chevR" size={12} color={DAANA.ink30} />
        <span>Seasonal mangoes</span><Icon name="chevR" size={12} color={DAANA.ink30} />
        <span style={{ color: DAANA.ink }}>Sindhri</span>
      </div>

      <div style={{ padding: '24px 56px 48px', display: 'grid', gridTemplateColumns: '1.1fr 1fr', gap: 56 }}>
        {/* Gallery */}
        <div>
          <div style={{ aspectRatio: '1 / 1', maxWidth: 620 }}>
            <ProductPlaceholder label="sindhri mango — hero" tone="c" radius={20} />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10, marginTop: 12, maxWidth: 620 }}>
            {['detail', 'flesh', 'in crate', 'scale'].map((l, i) => (
              <div key={i} style={{ aspectRatio: '1 / 1', border: i === 0 ? `1.5px solid ${DAANA.ink}` : `1px solid ${DAANA.hairlineSoft}`, borderRadius: 12, overflow: 'hidden' }}>
                <ProductPlaceholder label={l} tone="c" radius={10} />
              </div>
            ))}
          </div>
        </div>

        {/* Detail */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <Eyebrow>Seasonal · peaks now</Eyebrow>
            <div style={{ width: 4, height: 4, borderRadius: 999, background: DAANA.ink30 }} />
            <div style={{ fontFamily: DAANA.mono, fontSize: 10.5, letterSpacing: '0.1em', color: DAANA.moss, textTransform: 'uppercase' }}>
              Mirpurkhas · Sindh
            </div>
          </div>

          <h1 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 64, lineHeight: 1, letterSpacing: '-0.02em', margin: 0 }}>
            Sindhri Mango
          </h1>
          <div className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 28, color: DAANA.ink70, marginTop: -8 }}>
            سندھڑی آم
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <Price value={320} size={32} />
            <span style={{ fontSize: 13, color: DAANA.ink50 }}>per kg · ~6 fruits</span>
          </div>

          <p style={{ fontSize: 15, lineHeight: 1.6, color: DAANA.ink70, margin: 0, maxWidth: 480 }}>
            Picked yesterday at first light from a 40-year-old orchard outside Mirpurkhas. Fibrous, honey-sweet, with a clean
            finish. Best eaten within four days of arrival.
          </p>

          {/* Variant */}
          <div style={{ marginTop: 4 }}>
            <Eyebrow>Quantity</Eyebrow>
            <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
              {[
                { id: '500g', l: '500 g', p: 170 },
                { id: '1kg', l: '1 kg', p: 320, tag: 'Most picked' },
                { id: '5kg', l: '5 kg box', p: 1480, tag: 'Save Rs 120' },
              ].map(v => (
                <button key={v.id} onClick={() => setVariant(v.id)} style={{
                  flex: 1, padding: '14px 16px', borderRadius: 12,
                  border: `1.5px solid ${variant === v.id ? DAANA.ink : DAANA.hairlineSoft}`,
                  background: variant === v.id ? DAANA.card : 'transparent',
                  display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 4, textAlign: 'left',
                }}>
                  <div style={{ fontSize: 14, fontWeight: 500 }}>{v.l}</div>
                  <Price value={v.p} size={13} color={DAANA.ink70} />
                  {v.tag && <div style={{ fontFamily: DAANA.mono, fontSize: 9, color: DAANA.moss, letterSpacing: '0.1em', textTransform: 'uppercase' }}>{v.tag}</div>}
                </button>
              ))}
            </div>
          </div>

          {/* CTA */}
          <div style={{ display: 'flex', gap: 12, alignItems: 'center', marginTop: 4 }}>
            <div style={{
              display: 'flex', alignItems: 'center', border: `1px solid ${DAANA.hairline}`,
              borderRadius: 999, height: 48,
            }}>
              <button onClick={() => setQty(Math.max(1, qty - 1))} style={{ width: 44, height: 48, background: 'transparent', border: 'none' }}>
                <Icon name="minus" size={16} />
              </button>
              <div style={{ width: 32, textAlign: 'center', fontSize: 16, fontVariantNumeric: 'tabular-nums' }}>{qty}</div>
              <button onClick={() => setQty(qty + 1)} style={{ width: 44, height: 48, background: 'transparent', border: 'none' }}>
                <Icon name="plus" size={16} />
              </button>
            </div>
            <Btn variant="primary" size="lg" iconRight="arrowR" style={{ flex: 1 }}>
              Add to cart · Rs {(320 * qty).toLocaleString('en-PK')}
            </Btn>
            <Btn variant="ghost" size="lg" icon="heart" />
          </div>

          {/* Meta */}
          <div style={{ marginTop: 8, display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 0, border: `1px solid ${DAANA.hairlineSoft}`, borderRadius: 12 }}>
            {[
              { i: 'truck', t: 'Today, 6–8 pm', s: 'Free over Rs 1,500' },
              { i: 'leaf', t: 'Picked 22 May', s: 'Cold-stored 4°C' },
              { i: 'check', t: '7-day freshness', s: '100% refund if not' },
            ].map((m, i) => (
              <div key={i} style={{
                padding: 14, borderRight: i < 2 ? `1px solid ${DAANA.hairlineSoft}` : 'none',
                display: 'flex', flexDirection: 'column', gap: 6,
              }}>
                <Icon name={m.i} size={16} color={DAANA.moss} />
                <div style={{ fontSize: 13 }}>{m.t}</div>
                <div style={{ fontSize: 11.5, color: DAANA.ink50 }}>{m.s}</div>
              </div>
            ))}
          </div>

          {/* AI recipes from this product */}
          <div style={{ marginTop: 16, padding: 20, background: DAANA.card, borderRadius: 16, border: `1px solid ${DAANA.hairlineSoft}` }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
              <Icon name="sparkle" size={14} color={DAANA.moss} />
              <Eyebrow>What to make with Sindhri</Eyebrow>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
              {[
                { t: 'Aam ka achaar', s: '6 ingredients · 30 m' },
                { t: 'Mango lassi', s: '4 ingredients · 5 m' },
                { t: 'Mango kulfi', s: '5 ingredients · 4 h' },
              ].map((r, i) => (
                <button key={i} style={{
                  background: DAANA.bg, border: `1px solid ${DAANA.hairlineSoft}`, borderRadius: 12, padding: 12,
                  display: 'flex', alignItems: 'center', gap: 10, textAlign: 'left',
                }}>
                  <div style={{ width: 36, height: 36, flexShrink: 0 }}>
                    <ProductPlaceholder label="" tone="c" radius={6} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13 }}>{r.t}</div>
                    <div style={{ fontSize: 11, color: DAANA.ink50 }}>{r.s}</div>
                  </div>
                  <Icon name="chevR" size={14} color={DAANA.ink50} />
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

window.ProductDetail = ProductDetail;
