// AI Recipe Generator — daana
// User types what they have → AI suggests recipes

function AIRecipePage() {
  const [phase, setPhase] = React.useState('result'); // 'input' | 'thinking' | 'result'
  const [ingredients, setIngredients] = React.useState(['chicken breast', 'tomato', 'onion', 'ginger', 'dahi', 'green chilies']);
  const [draft, setDraft] = React.useState('');
  const [selected, setSelected] = React.useState(0);

  const suggestions = [
    {
      name: 'Chicken Karahi', urdu: 'مرغی کڑاہی',
      time: '35 min', servings: 4, level: 'Easy', spice: 'Medium-hot',
      blurb: 'A bright, tomato-forward karahi finished with fresh ginger and green chilies. Cooked in a single wide pan.',
      have: ['chicken breast', 'tomato', 'onion', 'ginger', 'green chilies'],
      need: [
        { name: 'Coriander', unit: '50 g', price: 20 },
        { name: 'Lemon', unit: '2 pcs', price: 60 },
        { name: 'Whole spices (kit)', unit: '1 sachet', price: 90 },
      ],
    },
    {
      name: 'Murgh Cholay', urdu: 'مرغ چنے',
      time: '50 min', servings: 4, level: 'Medium', spice: 'Mild',
      blurb: 'Slow-built chickpea curry with shredded chicken, perfect with naan or rice.',
      have: ['chicken breast', 'tomato', 'onion', 'ginger', 'dahi'],
      need: [
        { name: 'Kabuli chana', unit: '500 g', price: 280 },
        { name: 'Garam masala', unit: '50 g', price: 110 },
      ],
    },
    {
      name: 'Dahi Chicken', urdu: 'دہی مرغی',
      time: '25 min', servings: 3, level: 'Easy', spice: 'Mild',
      blurb: 'Yogurt-tenderized chicken in a creamy, almost-sweet sauce. Done in one pan.',
      have: ['chicken breast', 'onion', 'ginger', 'dahi', 'green chilies'],
      need: [
        { name: 'Cashews', unit: '100 g', price: 280 },
        { name: 'Coriander', unit: '50 g', price: 20 },
      ],
    },
  ];

  const r = suggestions[selected];

  return (
    <div className="daana" style={{ background: DAANA.bg, minHeight: '100%' }}>
      <NavBar />

      {/* Header */}
      <div style={{ padding: '32px 56px 24px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 24 }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 28, height: 28, borderRadius: 999, background: DAANA.moss, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="sparkle" size={14} color={DAANA.bg} />
            </div>
            <Eyebrow>Assistant · Recipes from your fridge</Eyebrow>
          </div>
          <h1 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 56, lineHeight: 1, margin: '12px 0 0', letterSpacing: '-0.02em', maxWidth: 760 }}>
            Three things you can cook tonight, with what you already have.
          </h1>
        </div>
      </div>

      <div style={{ padding: '24px 56px 80px', display: 'grid', gridTemplateColumns: '380px 1fr', gap: 32 }}>
        {/* Input / pantry */}
        <aside>
          <div style={{ background: DAANA.card, borderRadius: 20, padding: 24, border: `1px solid ${DAANA.hairlineSoft}` }}>
            <Eyebrow>In your fridge</Eyebrow>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 14 }}>
              {ingredients.map((ing, i) => (
                <span key={i} style={{
                  display: 'inline-flex', alignItems: 'center', gap: 6, padding: '6px 10px 6px 12px',
                  background: DAANA.bg, border: `1px solid ${DAANA.hairlineSoft}`, borderRadius: 999, fontSize: 13,
                }}>
                  {ing}
                  <button onClick={() => setIngredients(ingredients.filter((_, j) => j !== i))} style={{ background: 'transparent', border: 'none', color: DAANA.ink50, padding: 0, display: 'flex' }}>
                    <Icon name="close" size={11} />
                  </button>
                </span>
              ))}
            </div>
            <div style={{ marginTop: 14, display: 'flex', gap: 8 }}>
              <input
                value={draft}
                onChange={e => setDraft(e.target.value)}
                onKeyDown={e => { if (e.key === 'Enter' && draft.trim()) { setIngredients([...ingredients, draft.trim()]); setDraft(''); } }}
                placeholder="add another…"
                style={{
                  flex: 1, height: 40, padding: '0 14px', borderRadius: 999, border: `1px solid ${DAANA.hairline}`,
                  background: DAANA.bg, fontSize: 13, outline: 'none', color: DAANA.ink,
                }}
              />
              <button style={{
                width: 40, height: 40, borderRadius: 999, background: DAANA.ink08, border: 'none',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon name="mic" size={15} />
              </button>
            </div>
            <Hr style={{ margin: '20px 0' }} />
            <Eyebrow>Preferences</Eyebrow>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 12 }}>
              {['Under 30 min', 'No oven', 'Mild spice', 'Family-size'].map((p, i) => (
                <Chip key={i} active={i === 0}>{p}</Chip>
              ))}
            </div>
          </div>

          <div style={{ marginTop: 16, padding: 16, fontSize: 12, color: DAANA.ink50, lineHeight: 1.5 }}>
            Daana's recipe assistant uses your pantry + recent orders. Nothing is sent to outside services.
          </div>
        </aside>

        {/* Result */}
        <div>
          {/* Tabs */}
          <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
            {suggestions.map((s, i) => (
              <button key={i} onClick={() => setSelected(i)} style={{
                padding: '14px 18px', borderRadius: 14,
                background: selected === i ? DAANA.ink : DAANA.card,
                color: selected === i ? DAANA.bg : DAANA.ink,
                border: `1px solid ${selected === i ? DAANA.ink : DAANA.hairlineSoft}`,
                textAlign: 'left', display: 'flex', flexDirection: 'column', gap: 4, flex: 1,
              }}>
                <div style={{ fontFamily: DAANA.mono, fontSize: 10, opacity: 0.6, letterSpacing: '0.15em' }}>
                  OPTION {String(i + 1).padStart(2, '0')}
                </div>
                <div className="serif" style={{ fontFamily: DAANA.serif, fontSize: 22, lineHeight: 1, letterSpacing: '-0.01em' }}>
                  {s.name}
                </div>
                <div style={{ fontSize: 11, opacity: 0.75 }}>{s.time} · {s.level}</div>
              </button>
            ))}
          </div>

          {/* Recipe card */}
          <div style={{ background: DAANA.card, borderRadius: 24, border: `1px solid ${DAANA.hairlineSoft}`, overflow: 'hidden' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', minHeight: 320 }}>
              <div style={{ padding: 32, display: 'flex', flexDirection: 'column', gap: 16 }}>
                <Eyebrow>Suggestion · 92% match</Eyebrow>
                <div>
                  <h2 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 52, lineHeight: 1, letterSpacing: '-0.02em', margin: 0 }}>
                    {r.name}
                  </h2>
                  <div className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 28, color: DAANA.ink70, marginTop: 6 }}>{r.urdu}</div>
                </div>
                <p style={{ fontSize: 15, lineHeight: 1.55, color: DAANA.ink70, margin: 0 }}>{r.blurb}</p>
                <div style={{ display: 'flex', gap: 24, paddingTop: 8 }}>
                  {[
                    { l: 'Time', v: r.time },
                    { l: 'Serves', v: r.servings },
                    { l: 'Level', v: r.level },
                    { l: 'Spice', v: r.spice },
                  ].map((m, i) => (
                    <div key={i}>
                      <Eyebrow>{m.l}</Eyebrow>
                      <div style={{ fontSize: 16, marginTop: 4 }}>{m.v}</div>
                    </div>
                  ))}
                </div>
              </div>
              <div style={{ position: 'relative' }}>
                <ProductPlaceholder label={`${r.name.toLowerCase()} — plated`} tone="c" radius={0} square={false} />
              </div>
            </div>

            <Hr />

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', minHeight: 200 }}>
              <div style={{ padding: 28, borderRight: `1px solid ${DAANA.hairlineSoft}` }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <Eyebrow>You have · {r.have.length}</Eyebrow>
                  <Icon name="check" size={14} color={DAANA.moss} />
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 14 }}>
                  {r.have.map((h, i) => (
                    <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, fontSize: 14 }}>
                      <div style={{ width: 16, height: 16, borderRadius: 999, background: DAANA.moss, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                        <Icon name="check" size={10} color={DAANA.bg} stroke={2.5} />
                      </div>
                      <span style={{ color: DAANA.ink }}>{h}</span>
                    </div>
                  ))}
                </div>
              </div>
              <div style={{ padding: 28, background: DAANA.bgAlt }}>
                <Eyebrow>Daana can add · {r.need.length}</Eyebrow>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 14 }}>
                  {r.need.map((n, i) => (
                    <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, fontSize: 14 }}>
                      <div style={{ width: 6, height: 6, borderRadius: 999, background: DAANA.ink30 }} />
                      <span style={{ flex: 1 }}>{n.name}</span>
                      <span style={{ fontSize: 12, color: DAANA.ink50 }}>{n.unit}</span>
                      <Price value={n.price} size={13} />
                    </div>
                  ))}
                  <Hr style={{ margin: '6px 0' }} />
                  <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
                    <span style={{ fontSize: 13, color: DAANA.ink70 }}>Add to basket</span>
                    <Price value={r.need.reduce((s, n) => s + n.price, 0)} size={18} />
                  </div>
                  <Btn variant="moss" size="md" full iconRight="arrowR" style={{ marginTop: 6 }}>Add {r.need.length} ingredients</Btn>
                </div>
              </div>
            </div>

            <Hr />

            {/* Steps preview */}
            <div style={{ padding: 28 }}>
              <Eyebrow>How to · 4 steps</Eyebrow>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginTop: 16 }}>
                {[
                  'Sear chicken in ghee, two minutes a side, set aside.',
                  'Sauté onion & ginger until amber. Add tomatoes & spices.',
                  'Return chicken, cover, simmer 12 minutes.',
                  'Finish with green chilies, julienned ginger, fresh coriander.',
                ].map((s, i) => (
                  <div key={i} style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                    <div style={{ fontFamily: DAANA.mono, fontSize: 11, color: DAANA.moss, letterSpacing: '0.1em' }}>
                      STEP {String(i + 1).padStart(2, '0')}
                    </div>
                    <div style={{ fontSize: 13, lineHeight: 1.45, color: DAANA.ink70 }}>{s}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

window.AIRecipePage = AIRecipePage;
