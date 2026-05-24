// Desktop Search & Category Browse — daana

function SearchBrowse() {
  const [q, setQ] = React.useState('palak');
  const [sort, setSort] = React.useState('popular');

  const results = [
    { ...PRODUCTS.spinach },
    { ...PRODUCTS.coriander, name: 'Hara Dhania', price: 30 },
    { ...PRODUCTS.greenChili },
    { ...PRODUCTS.paneer },
    { ...PRODUCTS.ginger },
    { ...PRODUCTS.garlic },
    { ...PRODUCTS.tomatoes },
    { ...PRODUCTS.onions },
  ];

  return (
    <div className="daana" style={{ background: DAANA.bg, minHeight: '100%' }}>
      <NavBar />

      {/* Breadcrumb */}
      <div style={{ padding: '24px 56px 0', display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: DAANA.ink50 }}>
        <span>Shop</span>
        <Icon name="chevR" size={12} color={DAANA.ink30} />
        <span>Vegetables</span>
        <Icon name="chevR" size={12} color={DAANA.ink30} />
        <span style={{ color: DAANA.ink }}>"{q}"</span>
      </div>

      {/* Header */}
      <div style={{ padding: '20px 56px 32px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 24 }}>
        <div>
          <Eyebrow>Search results</Eyebrow>
          <h1 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 56, lineHeight: 1, letterSpacing: '-0.02em', margin: '8px 0 0' }}>
            "{q}" <span style={{ color: DAANA.ink30 }}>· {results.length}</span>
          </h1>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <Eyebrow>Sort</Eyebrow>
          <div style={{ display: 'flex', gap: 0, background: DAANA.card, borderRadius: 999, padding: 4, border: `1px solid ${DAANA.hairlineSoft}` }}>
            {[
              { id: 'popular', l: 'Popular' },
              { id: 'price', l: 'Price' },
              { id: 'fresh', l: 'Freshest' },
            ].map(o => (
              <button key={o.id} onClick={() => setSort(o.id)} style={{
                height: 32, padding: '0 14px', borderRadius: 999, border: 'none',
                background: sort === o.id ? DAANA.ink : 'transparent', color: sort === o.id ? DAANA.bg : DAANA.ink70, fontSize: 13,
              }}>{o.l}</button>
            ))}
          </div>
        </div>
      </div>

      {/* Body */}
      <div style={{ padding: '0 56px 80px', display: 'grid', gridTemplateColumns: '260px 1fr', gap: 32 }}>
        {/* Filters */}
        <aside style={{ position: 'sticky', top: 96, alignSelf: 'flex-start' }}>
          <FilterGroup title="Category" items={[
            { l: 'Leafy greens', n: 12, on: true },
            { l: 'Herbs', n: 8 },
            { l: 'Frozen', n: 3 },
            { l: 'Tomato & pepper', n: 14 },
            { l: 'Onion & garlic', n: 9 },
          ]} />
          <FilterGroup title="Sourcing" items={[
            { l: 'Local · Sindh', n: 22, on: true },
            { l: 'Local · Punjab', n: 31 },
            { l: 'Organic certified', n: 7 },
          ]} />
          <FilterGroup title="Price" items={[
            { l: 'Under Rs 100', n: 18 },
            { l: 'Rs 100 – 250', n: 24 },
            { l: 'Rs 250 +', n: 11 },
          ]} />
          <button style={{
            marginTop: 16, fontSize: 13, color: DAANA.ink70, background: 'transparent', border: 'none',
            padding: 0, display: 'flex', alignItems: 'center', gap: 6,
          }}>
            <Icon name="close" size={12} /> Clear all filters
          </button>
        </aside>

        {/* Grid */}
        <div>
          {/* In-line AI suggestion */}
          <div style={{
            background: DAANA.card, border: `1px dashed ${DAANA.moss}`, borderRadius: 16, padding: 18,
            display: 'flex', alignItems: 'center', gap: 16, marginBottom: 20,
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 999, background: DAANA.moss,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon name="sparkle" size={16} color={DAANA.bg} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, color: DAANA.ink }}>
                Cooking <span style={{ fontStyle: 'italic' }}>palak paneer</span>? Add the 6 ingredients in one tap.
              </div>
              <div style={{ fontSize: 12, color: DAANA.ink50, marginTop: 2 }}>
                Palak · paneer · onion · tomato · ginger · garlic — for 4 servings, Rs 1,180
              </div>
            </div>
            <Btn variant="moss" size="sm" iconRight="arrowR">Add recipe</Btn>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16 }}>
            {results.map((p, i) => <ProductCard key={i} p={p} onAdd={() => {}} />)}
          </div>
        </div>
      </div>
    </div>
  );
}

function FilterGroup({ title, items }) {
  return (
    <div style={{ marginBottom: 28 }}>
      <Eyebrow>{title}</Eyebrow>
      <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {items.map((it, i) => (
          <label key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer', fontSize: 13.5 }}>
            <span style={{
              width: 16, height: 16, borderRadius: 4, border: `1.5px solid ${it.on ? DAANA.ink : DAANA.hairline}`,
              background: it.on ? DAANA.ink : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0,
            }}>
              {it.on && <Icon name="check" size={11} color={DAANA.bg} stroke={2} />}
            </span>
            <span style={{ flex: 1, color: DAANA.ink }}>{it.l}</span>
            <span style={{ fontFamily: DAANA.mono, fontSize: 10.5, color: DAANA.ink30 }}>{it.n}</span>
          </label>
        ))}
      </div>
    </div>
  );
}

window.SearchBrowse = SearchBrowse;
