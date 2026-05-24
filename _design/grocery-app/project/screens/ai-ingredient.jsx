// AI Ingredient Finder — daana
// User types a dish → AI fills the basket with ingredients

function AIIngredientPage() {
  const [dish] = React.useState('Chicken karahi for 4');
  const [servings, setServings] = React.useState(4);
  const [checkedAll, setCheckedAll] = React.useState(true);

  const ingredients = [
    { k: 'chickenBreast', qty: '1 kg', need: '800 g', note: 'bone-in if preferred', on: true, group: 'Protein' },
    { k: 'tomatoes', qty: '750 g', need: '6 medium', on: true, group: 'Produce' },
    { k: 'onions', qty: '500 g', need: '4 medium', on: true, group: 'Produce' },
    { k: 'ginger', qty: '50 g', need: '2 inch', on: true, group: 'Produce' },
    { k: 'garlic', qty: '40 g', need: '8 cloves', on: true, group: 'Produce' },
    { k: 'greenChili', qty: '40 g', need: '6 pcs', note: 'adjust to taste', on: true, group: 'Produce' },
    { k: 'coriander', qty: '50 g', need: '1 small bunch', on: true, group: 'Produce' },
    { k: 'yogurt', qty: '250 g', need: '1 cup', on: true, group: 'Dairy' },
    { k: 'oil', qty: '100 ml', need: '½ cup', note: 'ghee works too', on: false, group: 'Pantry' },
  ];

  const subtotal = ingredients.filter(i => i.on).reduce((s, i) => s + PRODUCTS[i.k].price, 0);

  return (
    <div className="daana" style={{ background: DAANA.bg, minHeight: '100%' }}>
      <NavBar />

      {/* Header */}
      <div style={{ padding: '32px 56px 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 28, height: 28, borderRadius: 999, background: DAANA.moss, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="book" size={14} color={DAANA.bg} />
          </div>
          <Eyebrow>Assistant · Cook this</Eyebrow>
        </div>
      </div>

      <div style={{ padding: '0 56px 24px' }}>
        {/* Search box */}
        <div style={{
          background: DAANA.card, borderRadius: 24, padding: '14px 14px 14px 24px',
          border: `1px solid ${DAANA.hairlineSoft}`,
          display: 'flex', alignItems: 'center', gap: 16,
        }}>
          <Icon name="sparkle" size={18} color={DAANA.moss} />
          <input
            defaultValue={dish}
            style={{
              flex: 1, border: 'none', background: 'transparent', outline: 'none',
              fontFamily: DAANA.serif, fontSize: 30, color: DAANA.ink, letterSpacing: '-0.01em', padding: '8px 0',
            }}
          />
          <button style={{
            height: 44, width: 44, borderRadius: 999, background: DAANA.ink08, border: 'none',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="mic" size={16} />
          </button>
          <Btn variant="primary" size="lg" iconRight="arrowR">Find ingredients</Btn>
        </div>

        {/* Suggested searches */}
        <div style={{ display: 'flex', gap: 8, marginTop: 12, flexWrap: 'wrap' }}>
          {['Aloo gosht', 'Daal chawal', 'Mutton biryani for 6', 'Pasta carbonara', 'Hyderabadi haleem', 'Quick breakfast for 2'].map((s, i) => (
            <Chip key={i}>{s}</Chip>
          ))}
        </div>
      </div>

      {/* Body */}
      <div style={{ padding: '24px 56px 80px', display: 'grid', gridTemplateColumns: '1fr 380px', gap: 32 }}>
        {/* Ingredient list */}
        <div>
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 20 }}>
            <div>
              <Eyebrow>9 ingredients matched · 8 in stock</Eyebrow>
              <h2 className="serif" style={{ fontFamily: DAANA.serif, fontSize: 42, lineHeight: 1, margin: '8px 0 0', letterSpacing: '-0.02em' }}>
                Chicken Karahi
                <span className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 30, color: DAANA.ink50, marginLeft: 14 }}>کڑاہی</span>
              </h2>
            </div>
            {/* Servings stepper */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6, alignItems: 'flex-end' }}>
              <Eyebrow>Serves</Eyebrow>
              <div style={{ display: 'flex', alignItems: 'center', border: `1px solid ${DAANA.hairline}`, borderRadius: 999, height: 40 }}>
                <button onClick={() => setServings(Math.max(1, servings - 1))} style={{ width: 36, height: 40, background: 'transparent', border: 'none' }}>
                  <Icon name="minus" size={14} />
                </button>
                <div style={{ width: 36, textAlign: 'center', fontSize: 15, fontVariantNumeric: 'tabular-nums' }}>{servings}</div>
                <button onClick={() => setServings(servings + 1)} style={{ width: 36, height: 40, background: 'transparent', border: 'none' }}>
                  <Icon name="plus" size={14} />
                </button>
              </div>
            </div>
          </div>

          {/* Ingredient table */}
          <div style={{ background: DAANA.card, borderRadius: 20, border: `1px solid ${DAANA.hairlineSoft}`, overflow: 'hidden' }}>
            <div style={{
              display: 'grid', gridTemplateColumns: '40px 1fr 130px 130px 90px', gap: 0,
              padding: '12px 20px', background: DAANA.bgAlt, borderBottom: `1px solid ${DAANA.hairlineSoft}`,
            }}>
              <label style={{ display: 'flex', alignItems: 'center' }}>
                <span style={{
                  width: 16, height: 16, borderRadius: 4, border: `1.5px solid ${DAANA.ink}`,
                  background: checkedAll ? DAANA.ink : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {checkedAll && <Icon name="check" size={11} color={DAANA.bg} stroke={2} />}
                </span>
              </label>
              {['Ingredient', 'Recipe needs', 'Daana sells', 'Price'].map(h => (
                <div key={h} style={{ fontFamily: DAANA.mono, fontSize: 10, letterSpacing: '0.12em', color: DAANA.ink50, textTransform: 'uppercase' }}>{h}</div>
              ))}
            </div>

            {ingredients.map((ing, i) => {
              const p = PRODUCTS[ing.k];
              return (
                <div key={i} style={{
                  display: 'grid', gridTemplateColumns: '40px 1fr 130px 130px 90px',
                  alignItems: 'center', padding: '14px 20px',
                  borderBottom: i < ingredients.length - 1 ? `1px solid ${DAANA.hairlineSoft}` : 'none',
                  background: ing.on ? 'transparent' : 'rgba(26,24,20,0.02)',
                }}>
                  <span style={{
                    width: 16, height: 16, borderRadius: 4, border: `1.5px solid ${ing.on ? DAANA.ink : DAANA.hairline}`,
                    background: ing.on ? DAANA.ink : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    {ing.on && <Icon name="check" size={11} color={DAANA.bg} stroke={2} />}
                  </span>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                    <div style={{ width: 32, height: 32, flexShrink: 0 }}>
                      <ProductPlaceholder label="" tone={p.tone} radius={6} />
                    </div>
                    <div>
                      <div style={{ fontSize: 14, color: ing.on ? DAANA.ink : DAANA.ink50 }}>{p.name}</div>
                      <div style={{ fontSize: 11, color: DAANA.ink50 }}>{ing.note || ing.group}</div>
                    </div>
                  </div>
                  <div style={{ fontSize: 13, color: DAANA.ink70, fontVariantNumeric: 'tabular-nums' }}>{ing.need}</div>
                  <div style={{ fontSize: 13, color: DAANA.ink70, fontVariantNumeric: 'tabular-nums' }}>{ing.qty}</div>
                  <Price value={p.price} size={14} color={ing.on ? DAANA.ink : DAANA.ink50} />
                </div>
              );
            })}
          </div>

          {/* Method preview */}
          <div style={{ marginTop: 32 }}>
            <Eyebrow>How Daana sized this</Eyebrow>
            <div style={{ background: DAANA.card, borderRadius: 16, padding: 20, marginTop: 12, border: `1px solid ${DAANA.hairlineSoft}` }}>
              <div style={{ fontSize: 14, lineHeight: 1.6, color: DAANA.ink70 }}>
                Scaled for <strong style={{ color: DAANA.ink }}>{servings} servings</strong>. Estimated active time:
                <strong style={{ color: DAANA.ink }}> 35 minutes</strong>. We've unchecked sunflower oil since you bought a 3 L tin
                three weeks ago — it's likely still in your pantry. Pair with naan or basmati.
              </div>
            </div>
          </div>
        </div>

        {/* Sticky summary */}
        <aside style={{ position: 'sticky', top: 96, alignSelf: 'flex-start' }}>
          <div style={{ background: DAANA.ink, color: DAANA.bg, borderRadius: 20, padding: 24 }}>
            <Eyebrow style={{ color: 'rgba(246,243,236,0.55)' }}>You add</Eyebrow>
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginTop: 8 }}>
              <div className="serif" style={{ fontFamily: DAANA.serif, fontSize: 48, letterSpacing: '-0.02em', lineHeight: 1 }}>
                Rs {subtotal.toLocaleString('en-PK')}
              </div>
              <div style={{ fontSize: 12, color: 'rgba(246,243,236,0.6)' }}>{ingredients.filter(i => i.on).length} items</div>
            </div>
            <div style={{ fontSize: 13, color: 'rgba(246,243,236,0.7)', marginTop: 14, lineHeight: 1.45 }}>
              Plus what's already in your pantry. Delivery today, 6 – 8 pm.
            </div>
            <Btn variant="moss" size="lg" full iconRight="arrowR" style={{ marginTop: 18, background: DAANA.bg, color: DAANA.ink }}>
              Add all to cart
            </Btn>
            <button style={{
              marginTop: 10, width: '100%', background: 'transparent', border: '1px solid rgba(246,243,236,0.2)',
              color: DAANA.bg, height: 44, borderRadius: 999, fontSize: 14,
            }}>
              Save recipe
            </button>
          </div>

          {/* Substitutions */}
          <div style={{ marginTop: 16, background: DAANA.card, borderRadius: 16, padding: 20, border: `1px solid ${DAANA.hairlineSoft}` }}>
            <Eyebrow>Smart substitutions</Eyebrow>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 12, fontSize: 13, color: DAANA.ink70 }}>
              <div>• Dahi → cashew cream (vegan)</div>
              <div>• Chicken breast → boneless thigh (richer)</div>
              <div>• Tomato → tamarind paste (winter)</div>
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}

window.AIIngredientPage = AIIngredientPage;
