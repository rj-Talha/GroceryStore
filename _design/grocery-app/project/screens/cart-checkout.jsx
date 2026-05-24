// Desktop Cart & Checkout — daana

function CartCheckout() {
  const [items, setItems] = React.useState([
    { k: 'mangoesSindhri', q: 2 },
    { k: 'chickenBreast', q: 1 },
    { k: 'spinach', q: 2 },
    { k: 'yogurt', q: 1 },
    { k: 'naan', q: 2 },
    { k: 'chai', q: 1 },
  ]);

  const setQ = (i, q) => setItems(items.map((it, j) => j === i ? { ...it, q: Math.max(0, q) } : it).filter(it => it.q > 0));

  const subtotal = items.reduce((s, it) => s + PRODUCTS[it.k].price * it.q, 0);
  const delivery = subtotal >= 1500 ? 0 : 149;
  const total = subtotal + delivery;

  return (
    <div className="daana" style={{ background: DAANA.bg, minHeight: '100%' }}>
      <NavBar />

      <div style={{ padding: '32px 56px 16px' }}>
        <Eyebrow>Step 2 of 3 · Review</Eyebrow>
        <h1 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 56, lineHeight: 1, margin: '8px 0 0', letterSpacing: '-0.02em' }}>
          Your basket
        </h1>
      </div>

      <div style={{ padding: '24px 56px 80px', display: 'grid', gridTemplateColumns: '1fr 420px', gap: 40 }}>
        {/* Items */}
        <div>
          <Eyebrow style={{ marginBottom: 14 }}>{items.length} items · Delivery today, 6 – 8 pm</Eyebrow>
          <div style={{ background: DAANA.card, borderRadius: 16, border: `1px solid ${DAANA.hairlineSoft}` }}>
            {items.map((it, i) => {
              const p = PRODUCTS[it.k];
              return (
                <div key={i} style={{
                  display: 'grid', gridTemplateColumns: '72px 1fr auto auto auto', alignItems: 'center', gap: 16,
                  padding: '16px 20px', borderBottom: i < items.length - 1 ? `1px solid ${DAANA.hairlineSoft}` : 'none',
                }}>
                  <div style={{ width: 72, height: 72 }}>
                    <ProductPlaceholder label="" tone={p.tone} radius={10} />
                  </div>
                  <div>
                    <div style={{ fontSize: 15 }}>{p.name}</div>
                    <div style={{ fontSize: 12, color: DAANA.ink50, marginTop: 2 }}>{p.unit}</div>
                  </div>
                  <div style={{
                    display: 'flex', alignItems: 'center', border: `1px solid ${DAANA.hairline}`, borderRadius: 999, height: 34,
                  }}>
                    <button onClick={() => setQ(i, it.q - 1)} style={{ width: 32, height: 34, background: 'transparent', border: 'none' }}>
                      <Icon name="minus" size={13} />
                    </button>
                    <div style={{ width: 26, textAlign: 'center', fontSize: 13, fontVariantNumeric: 'tabular-nums' }}>{it.q}</div>
                    <button onClick={() => setQ(i, it.q + 1)} style={{ width: 32, height: 34, background: 'transparent', border: 'none' }}>
                      <Icon name="plus" size={13} />
                    </button>
                  </div>
                  <Price value={p.price * it.q} size={15} />
                  <button onClick={() => setQ(i, 0)} style={{ background: 'transparent', border: 'none', color: DAANA.ink30, padding: 6 }}>
                    <Icon name="close" size={14} />
                  </button>
                </div>
              );
            })}
          </div>

          {/* Suggested additions */}
          <div style={{ marginTop: 32 }}>
            <Eyebrow>Often bought together</Eyebrow>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginTop: 12 }}>
              {[PRODUCTS.tomatoes, PRODUCTS.onions, PRODUCTS.coriander, PRODUCTS.ginger].map((p, i) => (
                <div key={i} style={{
                  background: DAANA.card, border: `1px solid ${DAANA.hairlineSoft}`, borderRadius: 12, padding: 12,
                  display: 'flex', alignItems: 'center', gap: 10,
                }}>
                  <div style={{ width: 40, height: 40, flexShrink: 0 }}>
                    <ProductPlaceholder label="" tone={p.tone} radius={8} />
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 13, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.name}</div>
                    <Price value={p.price} size={12} color={DAANA.ink70} />
                  </div>
                  <button style={{
                    width: 28, height: 28, borderRadius: 999, background: DAANA.ink, color: DAANA.bg, border: 'none',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                  }}>
                    <Icon name="plus" size={12} color={DAANA.bg} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Summary */}
        <aside style={{ position: 'sticky', top: 96, alignSelf: 'flex-start' }}>
          <div style={{ background: DAANA.card, borderRadius: 16, padding: 24, border: `1px solid ${DAANA.hairlineSoft}` }}>
            <Eyebrow>Order summary</Eyebrow>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 16, fontSize: 14 }}>
              <Row l="Subtotal" v={`Rs ${subtotal.toLocaleString('en-PK')}`} />
              <Row l="Delivery" v={delivery === 0 ? 'Free' : `Rs ${delivery}`} accent={delivery === 0 ? DAANA.moss : null} />
              <Row l="Service fee" v="Rs 49" />
              <Hr style={{ margin: '6px 0' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
                <div style={{ fontSize: 14 }}>Total</div>
                <Price value={total + 49} size={26} />
              </div>
            </div>

            {/* Address */}
            <div style={{ marginTop: 20, paddingTop: 20, borderTop: `1px solid ${DAANA.hairlineSoft}` }}>
              <Eyebrow>Delivering to</Eyebrow>
              <div style={{ fontSize: 14, marginTop: 8, lineHeight: 1.4 }}>
                House 47-C, Khayaban-e-Bukhari<br/>DHA Phase VI, Karachi
              </div>
              <button style={{ marginTop: 8, fontSize: 12, background: 'transparent', border: 'none', color: DAANA.moss, padding: 0 }}>
                Change address
              </button>
            </div>

            {/* Payment */}
            <div style={{ marginTop: 20, paddingTop: 20, borderTop: `1px solid ${DAANA.hairlineSoft}` }}>
              <Eyebrow>Payment</Eyebrow>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 10 }}>
                {[
                  { l: 'Cash on delivery', d: 'Pay the rider' },
                  { l: 'JazzCash', d: '0300 ••• ••12' },
                  { l: 'Debit / credit card', d: 'Visa •• 4421', sel: true },
                ].map((m, i) => (
                  <label key={i} style={{
                    display: 'flex', alignItems: 'center', gap: 10, padding: '8px 0', cursor: 'pointer',
                  }}>
                    <span style={{
                      width: 16, height: 16, borderRadius: 999, border: `1.5px solid ${m.sel ? DAANA.ink : DAANA.hairline}`,
                      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                    }}>
                      {m.sel && <div style={{ width: 7, height: 7, borderRadius: 999, background: DAANA.ink }} />}
                    </span>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: 13 }}>{m.l}</div>
                      <div style={{ fontSize: 11, color: DAANA.ink50 }}>{m.d}</div>
                    </div>
                  </label>
                ))}
              </div>
            </div>

            <Btn variant="primary" size="lg" full iconRight="arrowR" style={{ marginTop: 20 }}>
              Place order
            </Btn>
            <div style={{ fontSize: 11, color: DAANA.ink50, textAlign: 'center', marginTop: 10, lineHeight: 1.4 }}>
              Free re-delivery for any item that doesn't meet our freshness bar.
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}

function Row({ l, v, accent }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
      <span style={{ color: DAANA.ink70 }}>{l}</span>
      <span style={{ color: accent || DAANA.ink, fontVariantNumeric: 'tabular-nums' }}>{v}</span>
    </div>
  );
}

window.CartCheckout = CartCheckout;
