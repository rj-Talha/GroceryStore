// Canvas — daana hi-fi UI

function App() {
  return (
    <DesignCanvas>
      <DCSection id="brand" title="01 — Identity" subtitle="A premium pantry for Pakistani kitchens. Bilingual EN/UR.">
        <DCArtboard id="brand-card" label="Brand · system" width={1280} height={720}>
          <BrandCard />
        </DCArtboard>
      </DCSection>

      <DCSection id="desktop" title="02 — Web · Desktop" subtitle="1440-wide. Browse, AI helpers, checkout.">
        <DCArtboard id="home-d" label="Home · recommendations + categories" width={1440} height={2400}>
          <ChromeWindow tabs={[{ title: 'daana — pantry, perfected' }, { title: 'Recipes' }]} activeIndex={0} url="daana.pk" width={1440} height={2400}>
            <HomeDesktop />
          </ChromeWindow>
        </DCArtboard>

        <DCArtboard id="search-d" label="Search · category browse" width={1440} height={1200}>
          <ChromeWindow tabs={[{ title: 'palak — daana' }]} activeIndex={0} url="daana.pk/search?q=palak" width={1440} height={1200}>
            <SearchBrowse />
          </ChromeWindow>
        </DCArtboard>

        <DCArtboard id="pdp-d" label="Product detail · Sindhri Mango" width={1440} height={1100}>
          <ChromeWindow tabs={[{ title: 'Sindhri Mango — daana' }]} activeIndex={0} url="daana.pk/p/sindhri-mango" width={1440} height={1100}>
            <ProductDetail />
          </ChromeWindow>
        </DCArtboard>

        <DCArtboard id="cart-d" label="Cart · checkout" width={1440} height={1280}>
          <ChromeWindow tabs={[{ title: 'Basket — daana' }]} activeIndex={0} url="daana.pk/basket" width={1440} height={1280}>
            <CartCheckout />
          </ChromeWindow>
        </DCArtboard>
      </DCSection>

      <DCSection id="ai" title="03 — AI helpers" subtitle="Quiet, useful. Recipe from your fridge, ingredients from a dish name.">
        <DCArtboard id="recipe-ai" label="AI · recipes from your fridge" width={1440} height={1280}>
          <ChromeWindow tabs={[{ title: 'Assistant — recipes' }]} activeIndex={0} url="daana.pk/assistant/recipes" width={1440} height={1280}>
            <AIRecipePage />
          </ChromeWindow>
        </DCArtboard>

        <DCArtboard id="ingredient-ai" label="AI · cook this — auto-basket" width={1440} height={1280}>
          <ChromeWindow tabs={[{ title: 'Assistant — ingredients' }]} activeIndex={0} url="daana.pk/assistant/cook-this" width={1440} height={1280}>
            <AIIngredientPage />
          </ChromeWindow>
        </DCArtboard>
      </DCSection>

      <DCSection id="mobile" title="04 — Mobile · iOS" subtitle="Same system on the phone — voice & AI made for one-handed use.">
        <DCArtboard id="mhome" label="Mobile · home" width={402} height={874}>
          <IOSDevice width={402} height={874}>
            <MobileHome />
          </IOSDevice>
        </DCArtboard>

        <DCArtboard id="mvoice" label="Mobile · voice order (Urdu)" width={402} height={874}>
          <IOSDevice width={402} height={874}>
            <MobileVoice />
          </IOSDevice>
        </DCArtboard>

        <DCArtboard id="mrecipe" label="Mobile · AI recipes" width={402} height={874}>
          <IOSDevice width={402} height={874}>
            <MobileAIRecipe />
          </IOSDevice>
        </DCArtboard>

        <DCArtboard id="voice-modal" label="Voice modal · desktop (Urdu)" width={900} height={760}>
          <div style={{ position: 'relative', width: '100%', height: '100%', background: '#1a1814' }}>
            <VoiceModalStatic lang="ur" />
          </div>
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

// Wrap VoiceModal so the static demo doesn't auto-dismiss the page
function VoiceModalStatic({ lang }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, background: 'rgba(26,24,20,0.45)',
      backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 40,
    }}>
      <VoiceModalContent lang={lang} />
    </div>
  );
}

function VoiceModalContent({ lang }) {
  const items = [
    { match: 'tomatoes', qty: '1 kg' },
    { match: 'milk', qty: '2 L' },
    { match: 'beefMince', qty: '500 g' },
  ];
  return (
    <div className="daana" style={{
      width: 560, background: DAANA.bg, borderRadius: 24, padding: 36, position: 'relative',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24 }}>
        <Eyebrow>Voice order · beta</Eyebrow>
        <div style={{ display: 'flex', gap: 4, padding: 4, background: DAANA.ink08, borderRadius: 999 }}>
          <button style={{ height: 28, padding: '0 14px', borderRadius: 999, border: 'none', background: 'transparent', color: DAANA.ink, fontSize: 12 }}>English</button>
          <button style={{ height: 28, padding: '0 14px', borderRadius: 999, border: 'none', background: DAANA.ink, color: DAANA.bg, fontSize: 12 }}>اردو</button>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16, padding: '8px 0 24px' }}>
        <div style={{ position: 'relative', width: 96, height: 96, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ position: 'absolute', inset: 0, borderRadius: 999, background: DAANA.moss, animation: 'daana-pulse 1.4s ease-in-out infinite', opacity: 0.18 }} />
          <div style={{ width: 72, height: 72, borderRadius: 999, background: DAANA.moss, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="mic" size={28} color={DAANA.bg} />
          </div>
        </div>
        <div style={{ display: 'flex', gap: 3, alignItems: 'center', height: 36 }}>
          {Array.from({ length: 32 }).map((_, i) => (
            <div key={i} style={{
              width: 3, height: 4 + (Math.sin(i * 0.7) + 1) * 14, background: DAANA.moss, borderRadius: 2,
              animation: `daana-wave 0.${4 + (i % 6)}s ease-in-out infinite`, opacity: 0.85,
            }} />
          ))}
        </div>
        <div style={{ fontSize: 13, color: DAANA.ink50 }}>Got it.</div>
      </div>
      <div style={{ background: DAANA.card, borderRadius: 16, padding: 20, border: `1px solid ${DAANA.hairlineSoft}` }}>
        <Eyebrow style={{ fontSize: 9 }}>Heard</Eyebrow>
        <div className="urdu" style={{ fontFamily: DAANA.urdu, fontSize: 26, marginTop: 8, color: DAANA.ink, lineHeight: 1.6 }}>
          ایک کلو ٹماٹر، دو لیٹر دودھ اور آدھا کلو قیمہ۔
        </div>
        <div style={{ fontSize: 12, color: DAANA.ink50, marginTop: 8, fontStyle: 'italic' }}>
          A dozen tomatoes (one kilo), two litres milk, and half a kilo of qeema.
        </div>
      </div>
      <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {items.map((it, i) => {
          const p = PRODUCTS[it.match];
          return (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: 10,
              background: DAANA.card, borderRadius: 12, border: `1px solid ${DAANA.hairlineSoft}`,
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
          <Btn variant="primary" size="md" iconRight="arrowR" style={{ flex: 1 }}>Add 3 items to cart</Btn>
        </div>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
