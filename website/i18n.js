const LANGS={
en:{flag:"🇺🇸",name:"English"},
vi:{flag:"🇻🇳",name:"Tiếng Việt"},
ja:{flag:"🇯🇵",name:"日本語"},
ko:{flag:"🇰🇷",name:"한국어"},
"zh-Hans":{flag:"🇨🇳",name:"简体中文"},
"zh-Hant":{flag:"🇹🇼",name:"繁體中文"},
es:{flag:"🇪🇸",name:"Español"},
fr:{flag:"🇫🇷",name:"Français"},
de:{flag:"🇩🇪",name:"Deutsch"},
"pt-BR":{flag:"🇧🇷",name:"Português"},
ru:{flag:"🇷🇺",name:"Русский"},
it:{flag:"🇮🇹",name:"Italiano"},
th:{flag:"🇹🇭",name:"ไทย"},
id:{flag:"🇮🇩",name:"Bahasa Indonesia"},
ar:{flag:"🇸🇦",name:"العربية"},
tr:{flag:"🇹🇷",name:"Türkçe"},
nl:{flag:"🇳🇱",name:"Nederlands"},
pl:{flag:"🇵🇱",name:"Polski"}
};

const T={};

T.en={
"nav.features":"Features","nav.howItWorks":"How It Works","nav.pricing":"Support","nav.faq":"FAQ",
"hero.badge":"macOS Sonoma+ • Apple Silicon Optimized",
"hero.title1":"Preview any window.","hero.title2":"Just hover the Dock.",
"hero.subtitle":"MacPeek lets you peek into app windows by simply hovering over Dock icons. No clicks. No switching. Just instant previews.",
"hero.cta":"Download Free","hero.ctaSecondary":"See How It Works",
"hero.metaPrivacy":"Privacy-first","hero.metaLight":"Native & lightweight","hero.metaTrial":"Free & open source",
"features.tag":"Features","features.title":"Everything you need.<br>Nothing you don't.",
"features.realtime.title":"Real-time Previews","features.realtime.desc":"Instantly see live window thumbnails when you hover over any Dock icon. No delay, no lag.",
"features.multi.title":"Multi-window Support","features.multi.desc":"Apps with multiple windows show a beautiful grid preview. Click any thumbnail to switch directly.",
"features.multimon.title":"Multi-monitor Ready","features.multimon.desc":"Works perfectly with multiple displays. The preview always appears on the correct screen.",
"features.privacy.title":"Privacy First","features.privacy.desc":"Zero data collection. Zero analytics. Everything runs locally on your Mac. Period.",
"features.lightweight.title":"Lightweight","features.lightweight.desc":"Native Swift code with minimal idle CPU usage. Designed to stay out of your way until needed.",
"features.i18n.title":"18 Languages","features.i18n.desc":"Automatically adapts to your system language. English, Japanese, Korean, Chinese, and 14 more.",
"howItWorks.tag":"How It Works","howItWorks.title":"Three steps. That's it.",
"howItWorks.step1.title":"Install & Grant Permissions","howItWorks.step1.desc":"Drag MacPeek to Applications. Grant Accessibility and Screen Recording permissions in the guided setup.",
"howItWorks.step2.title":"Hover Any Dock Icon","howItWorks.step2.desc":"Move your cursor over any app icon in the Dock. A live preview of its windows appears instantly.",
"howItWorks.step3.title":"Click to Switch","howItWorks.step3.desc":"Click on any preview thumbnail to instantly switch to that specific window. Multitasking made effortless.",
"pricing.tag":"Support MacPeek","pricing.title":"Free forever. Supported by you.","pricing.subtitle":"No trial, license key, subscription, or tracking.",
"pricing.badge":"FREE & OPEN SOURCE","pricing.desc":"Download, use, inspect, and contribute.",
"pricing.f1":"✅ Every feature is free","pricing.f2":"✅ GPL-3.0 source code","pricing.f3":"✅ Automatic updates","pricing.f4":"✅ Apple-notarized builds","pricing.f5":"✅ No analytics or tracking",
"pricing.buyPaypal":"Donate with PayPal","pricing.buyLemon":"Star on GitHub",
"pricing.note":"Donations are optional. MacPeek stays free for everyone.",
"requirements.tag":"System Requirements","requirements.os":"macOS 14.0 (Sonoma) or later","requirements.chip":"Apple Silicon (M1/M2/M3/M4) or Intel","requirements.size":"Small native macOS utility","requirements.perm":"Accessibility & Screen Recording permissions",
"faq.tag":"FAQ","faq.title":"Frequently Asked Questions",
"faq.q1":"Why does MacPeek need Accessibility and Screen Recording?","faq.a1":"Accessibility is required to detect which Dock icon you're hovering over. Screen Recording is needed to capture live window thumbnails. MacPeek never records or saves any screen content.",
"faq.q2":"Is MacPeek safe? Why isn't it on the App Store?","faq.a2":"MacPeek is fully notarized by Apple. It's not on the App Store because the APIs it uses are restricted in the sandbox. Many popular Mac utilities like Alfred and BetterTouchTool distribute the same way.",
"faq.q3":"Does it work with multiple monitors?","faq.a3":"Yes! MacPeek automatically detects which screen your Dock is on and positions the preview correctly.",
"faq.q4":"Is MacPeek really free?","faq.a4":"Yes. Every feature is free and the source code is available under GPL-3.0.",
"faq.q5":"How do updates work?","faq.a5":"MacPeek checks the signed GitHub release feed daily and lets you install updates using Sparkle.",
"faq.q6":"How can I contribute?","faq.a6":"Report an issue, improve a translation, submit a pull request, star the repository, or support development.",
"footer.desc":"Dock window preview for macOS.<br>Built with ❤️ for Apple Silicon.",
"footer.support":"Support","footer.privacy":"Privacy Policy","footer.terms":"Source code"
};

T.vi={
"nav.features":"Tính năng","nav.howItWorks":"Cách hoạt động","nav.pricing":"Ủng hộ","nav.faq":"Hỏi đáp",
"hero.badge":"macOS Sonoma+ • Tối ưu Apple Silicon",
"hero.title1":"Xem trước mọi cửa sổ.","hero.title2":"Chỉ cần di chuột vào Dock.",
"hero.subtitle":"MacPeek cho phép bạn xem trước cửa sổ ứng dụng bằng cách di chuột qua biểu tượng Dock. Không cần nhấp. Không cần chuyển đổi.",
"hero.cta":"Tải miễn phí","hero.ctaSecondary":"Xem cách hoạt động",
"hero.metaPrivacy":"Bảo mật tuyệt đối","hero.metaLight":"Native & nhẹ","hero.metaTrial":"Miễn phí & mã nguồn mở",
"features.tag":"Tính năng","features.title":"Mọi thứ bạn cần.<br>Không gì thừa.",
"features.realtime.title":"Xem trước thời gian thực","features.realtime.desc":"Xem thumbnail cửa sổ ngay khi di chuột qua biểu tượng Dock.",
"features.multi.title":"Hỗ trợ nhiều cửa sổ","features.multi.desc":"Ứng dụng có nhiều cửa sổ hiển thị dạng lưới. Nhấp vào để chuyển đổi.",
"features.multimon.title":"Đa màn hình","features.multimon.desc":"Hoạt động hoàn hảo với nhiều màn hình. Preview luôn hiện đúng vị trí.",
"features.privacy.title":"Quyền riêng tư","features.privacy.desc":"Không thu thập dữ liệu. Không phân tích. Mọi thứ chạy cục bộ trên Mac.",
"features.lightweight.title":"Nhẹ nhàng","features.lightweight.desc":"Viết native bằng Swift, gần như không dùng CPU khi chờ. Chỉ xuất hiện khi bạn cần.",
"features.i18n.title":"18 ngôn ngữ","features.i18n.desc":"Tự động theo ngôn ngữ hệ thống. Tiếng Anh, Nhật, Hàn, Trung và 14 ngôn ngữ khác.",
"howItWorks.tag":"Cách hoạt động","howItWorks.title":"Ba bước. Chỉ vậy thôi.",
"howItWorks.step1.title":"Cài đặt & Cấp quyền","howItWorks.step1.desc":"Kéo MacPeek vào Applications. Cấp quyền Trợ năng và Ghi màn hình trong hướng dẫn.",
"howItWorks.step2.title":"Di chuột vào Dock","howItWorks.step2.desc":"Di chuột qua biểu tượng ứng dụng trên Dock. Preview hiện ngay lập tức.",
"howItWorks.step3.title":"Nhấp để chuyển","howItWorks.step3.desc":"Nhấp vào thumbnail để chuyển sang cửa sổ đó. Đa nhiệm dễ dàng.",
"pricing.tag":"Ủng hộ MacPeek","pricing.title":"Miễn phí mãi mãi. Được duy trì bởi bạn.","pricing.subtitle":"Không dùng thử, license key, subscription hay theo dõi.",
"pricing.badge":"MIỄN PHÍ & MÃ NGUỒN MỞ","pricing.desc":"Tải về, sử dụng, kiểm tra và đóng góp.",
"pricing.f1":"✅ Mọi tính năng đều miễn phí","pricing.f2":"✅ Mã nguồn GPL-3.0","pricing.f3":"✅ Tự động cập nhật","pricing.f4":"✅ Được Apple notarize","pricing.f5":"✅ Không analytics hoặc tracking",
"pricing.buyPaypal":"Ủng hộ qua PayPal","pricing.buyLemon":"Star trên GitHub",
"pricing.note":"Ủng hộ hoàn toàn tùy chọn. MacPeek luôn miễn phí cho mọi người.",
"requirements.tag":"Yêu cầu hệ thống","requirements.os":"macOS 14.0 (Sonoma) trở lên","requirements.chip":"Apple Silicon (M1/M2/M3/M4) hoặc Intel","requirements.size":"Tiện ích macOS native nhỏ gọn","requirements.perm":"Quyền Trợ năng & Ghi màn hình",
"faq.tag":"Hỏi đáp","faq.title":"Câu hỏi thường gặp",
"faq.q1":"Tại sao MacPeek cần quyền Trợ năng và Ghi màn hình?","faq.a1":"Trợ năng để phát hiện biểu tượng Dock bạn đang di chuột. Ghi màn hình để chụp thumbnail cửa sổ. MacPeek không bao giờ ghi hoặc lưu nội dung màn hình.",
"faq.q2":"MacPeek có an toàn không? Sao không có trên App Store?","faq.a2":"MacPeek được Apple công chứng (notarized). Không có trên App Store vì API sử dụng bị giới hạn trong sandbox. Nhiều ứng dụng phổ biến như Alfred, BetterTouchTool cũng phân phối tương tự.",
"faq.q3":"Có hoạt động với nhiều màn hình không?","faq.a3":"Có! MacPeek tự động phát hiện màn hình có Dock và hiển thị preview đúng vị trí.",
"faq.q4":"MacPeek có thật sự miễn phí?","faq.a4":"Có. Mọi tính năng đều miễn phí và mã nguồn được phát hành theo GPL-3.0.",
"faq.q5":"Cập nhật hoạt động thế nào?","faq.a5":"MacPeek kiểm tra bản phát hành đã ký trên GitHub hằng ngày và cài đặt bằng Sparkle.",
"faq.q6":"Tôi có thể đóng góp thế nào?","faq.a6":"Báo lỗi, cải thiện bản dịch, gửi pull request, star repo hoặc ủng hộ phát triển.",
"footer.desc":"Xem trước cửa sổ Dock cho macOS.<br>Được tạo với ❤️ cho Apple Silicon.",
"footer.support":"Ủng hộ","footer.privacy":"Chính sách bảo mật","footer.terms":"Mã nguồn"
};

T.ja={
"nav.features":"機能","nav.howItWorks":"使い方","nav.pricing":"支援","nav.faq":"よくある質問",
"hero.badge":"macOS Sonoma+ • Apple Silicon最適化",
"hero.title1":"あらゆるウィンドウをプレビュー。","hero.title2":"Dockにホバーするだけ。",
"hero.subtitle":"MacPeekはDockアイコンにマウスを乗せるだけでアプリウィンドウをプレビューできます。クリック不要。切り替え不要。",
"hero.cta":"無料ダウンロード","hero.ctaSecondary":"使い方を見る",
"hero.metaPrivacy":"プライバシー重視","hero.metaLight":"ネイティブ＆軽量","hero.metaTrial":"無料＆オープンソース",
"features.tag":"機能","features.title":"必要なものすべて。<br>余計なものなし。",
"features.realtime.title":"リアルタイムプレビュー","features.realtime.desc":"Dockアイコンにホバーすると即座にウィンドウサムネイルを表示。",
"features.multi.title":"マルチウィンドウ対応","features.multi.desc":"複数ウィンドウのアプリはグリッド表示。クリックで直接切り替え。",
"features.multimon.title":"マルチモニター対応","features.multimon.desc":"複数ディスプレイで完璧に動作。プレビューは正しい画面に表示。",
"features.privacy.title":"プライバシー優先","features.privacy.desc":"データ収集ゼロ。分析ゼロ。すべてMac上でローカル実行。",
"features.lightweight.title":"超軽量","features.lightweight.desc":"5MB未満、CPU・RAM使用量最小。必要になるまで存在を感じません。",
"features.i18n.title":"18言語対応","features.i18n.desc":"システム言語に自動対応。日本語、英語、韓国語、中国語など18言語。",
"howItWorks.tag":"使い方","howItWorks.title":"3ステップで完了。",
"howItWorks.step1.title":"インストール＆権限設定","howItWorks.step1.desc":"MacPeekをApplicationsにドラッグ。ガイドに従ってアクセシビリティと画面収録の権限を許可。",
"howItWorks.step2.title":"Dockアイコンにホバー","howItWorks.step2.desc":"Dock上のアプリアイコンにカーソルを合わせると、ウィンドウのプレビューが即座に表示。",
"howItWorks.step3.title":"クリックで切り替え","howItWorks.step3.desc":"プレビューサムネイルをクリックすると、そのウィンドウに直接切り替わります。",
"pricing.tag":"MacPeekを支援","pricing.title":"永久無料。あなたの支援で成長。","pricing.subtitle":"トライアル、ライセンスキー、サブスク、追跡なし。",
"pricing.badge":"無料＆オープンソース","pricing.desc":"ダウンロード、利用、確認、貢献できます。",
"pricing.f1":"✅ 全機能無料","pricing.f2":"✅ GPL-3.0ソースコード","pricing.f3":"✅ 自動アップデート","pricing.f4":"✅ Apple公証済みビルド","pricing.f5":"✅ 分析・追跡なし",
"pricing.buyPaypal":"PayPalで支援","pricing.buyLemon":"GitHubでStar",
"pricing.note":"寄付は任意です。MacPeekは誰でも無料で使えます。",
"requirements.tag":"動作環境","requirements.os":"macOS 14.0 (Sonoma) 以降","requirements.chip":"Apple Silicon (M1/M2/M3/M4) またはIntel","requirements.size":"小型のネイティブmacOSユーティリティ","requirements.perm":"アクセシビリティ＆画面収録の権限",
"faq.tag":"FAQ","faq.title":"よくある質問",
"faq.q1":"なぜアクセシビリティと画面収録が必要？","faq.a1":"アクセシビリティはDockアイコンのホバー検出に必要。画面収録はウィンドウサムネイルのキャプチャに必要。MacPeekは画面内容を記録・保存しません。",
"faq.q2":"安全ですか？なぜApp Storeにないの？","faq.a2":"MacPeekはAppleの公証済み。使用するAPIがApp Storeのサンドボックスで制限されているため。Alfred等の人気ツールも同様。",
"faq.q3":"マルチモニターで動く？","faq.a3":"はい！Dockのある画面を自動検出し、正しい位置にプレビューを表示します。",
"faq.q4":"本当に無料ですか？","faq.a4":"はい。全機能が無料で、ソースコードはGPL-3.0で公開されています。",
"faq.q5":"アップデート方法は？","faq.a5":"署名済みGitHubリリースを毎日確認し、Sparkleで更新します。",
"faq.q6":"貢献するには？","faq.a6":"Issue、翻訳、Pull Request、Star、または開発支援で参加できます。",
"footer.desc":"macOS用Dockウィンドウプレビュー。<br>Apple Siliconのために❤️で作成。",
"footer.support":"支援","footer.privacy":"プライバシーポリシー","footer.terms":"ソースコード"
};

T.ko={
"nav.features":"기능","nav.howItWorks":"사용 방법","nav.pricing":"후원","nav.faq":"FAQ",
"hero.badge":"macOS Sonoma+ • Apple Silicon 최적화",
"hero.title1":"모든 창을 미리보기.","hero.title2":"Dock에 호버하세요.",
"hero.subtitle":"MacPeek은 Dock 아이콘에 마우스를 올리면 앱 창을 미리 볼 수 있습니다. 클릭 불필요. 전환 불필요.",
"hero.cta":"무료 다운로드","hero.ctaSecondary":"사용 방법 보기",
"hero.metaPrivacy":"개인정보 보호","hero.metaLight":"네이티브 & 경량","hero.metaTrial":"무료 오픈 소스",
"features.tag":"기능","features.title":"필요한 모든 것.<br>불필요한 것은 없습니다.",
"features.realtime.title":"실시간 미리보기","features.realtime.desc":"Dock 아이콘에 호버하면 즉시 창 썸네일을 표시합니다.",
"features.multi.title":"다중 창 지원","features.multi.desc":"여러 창이 있는 앱은 그리드로 표시. 클릭하여 바로 전환.",
"features.multimon.title":"다중 모니터 지원","features.multimon.desc":"여러 디스플레이에서 완벽하게 작동. 미리보기는 항상 올바른 화면에 표시.",
"features.privacy.title":"개인정보 보호","features.privacy.desc":"데이터 수집 없음. 분석 없음. 모든 것이 Mac에서 로컬로 실행.",
"features.lightweight.title":"초경량","features.lightweight.desc":"5MB 미만, 최소 CPU 및 RAM 사용. 필요할 때까지 보이지 않습니다.",
"features.i18n.title":"18개 언어","features.i18n.desc":"시스템 언어에 자동 적응. 한국어, 영어, 일본어, 중국어 등 18개 언어.",
"howItWorks.tag":"사용 방법","howItWorks.title":"세 단계. 그게 전부입니다.",
"howItWorks.step1.title":"설치 및 권한 부여","howItWorks.step1.desc":"MacPeek을 Applications로 드래그. 안내에 따라 손쉬운 사용 및 화면 기록 권한을 부여.",
"howItWorks.step2.title":"Dock 아이콘에 호버","howItWorks.step2.desc":"Dock의 앱 아이콘 위로 커서를 이동하면 창 미리보기가 즉시 나타납니다.",
"howItWorks.step3.title":"클릭하여 전환","howItWorks.step3.desc":"미리보기 썸네일을 클릭하면 해당 창으로 바로 전환됩니다.",
"pricing.tag":"MacPeek 후원","pricing.title":"영원히 무료. 여러분의 후원으로 성장합니다.","pricing.subtitle":"체험판, 라이선스 키, 구독, 추적이 없습니다.",
"pricing.badge":"무료 & 오픈 소스","pricing.desc":"다운로드하고 사용하고 검토하고 기여하세요.",
"pricing.f1":"✅ 모든 기능 무료","pricing.f2":"✅ GPL-3.0 소스 코드","pricing.f3":"✅ 자동 업데이트","pricing.f4":"✅ Apple 공증 빌드","pricing.f5":"✅ 분석 및 추적 없음",
"pricing.buyPaypal":"PayPal로 후원","pricing.buyLemon":"GitHub Star",
"pricing.note":"후원은 선택 사항입니다. MacPeek은 모두에게 무료입니다.",
"requirements.tag":"시스템 요구 사항","requirements.os":"macOS 14.0 (Sonoma) 이상","requirements.chip":"Apple Silicon (M1/M2/M3/M4) 또는 Intel","requirements.size":"작은 네이티브 macOS 유틸리티","requirements.perm":"손쉬운 사용 및 화면 기록 권한",
"faq.tag":"FAQ","faq.title":"자주 묻는 질문",
"faq.q1":"왜 손쉬운 사용과 화면 기록이 필요한가요?","faq.a1":"손쉬운 사용은 Dock 아이콘 호버 감지에, 화면 기록은 창 썸네일 캡처에 필요합니다. MacPeek은 화면 내용을 저장하지 않습니다.",
"faq.q2":"안전한가요? 왜 App Store에 없나요?","faq.a2":"MacPeek은 Apple 공증을 받았습니다. 사용하는 API가 App Store 샌드박스에서 제한되어 있습니다.",
"faq.q3":"다중 모니터에서 작동하나요?","faq.a3":"네! Dock이 있는 화면을 자동 감지하여 올바른 위치에 미리보기를 표시합니다.",
"faq.q4":"정말 무료인가요?","faq.a4":"네. 모든 기능이 무료이며 소스 코드는 GPL-3.0으로 공개됩니다.",
"faq.q5":"업데이트는 어떻게 하나요?","faq.a5":"매일 서명된 GitHub 릴리스를 확인하고 Sparkle로 업데이트합니다.",
"faq.q6":"어떻게 기여할 수 있나요?","faq.a6":"이슈, 번역, Pull Request, Star 또는 후원으로 참여할 수 있습니다.",
"footer.desc":"macOS용 Dock 창 미리보기.<br>Apple Silicon을 위해 ❤️로 제작.",
"footer.support":"후원","footer.privacy":"개인정보 처리방침","footer.terms":"소스 코드"
};

// Alias common languages to English as fallback
["zh-Hans","zh-Hant","es","fr","de","pt-BR","ru","it","th","id","ar","tr","nl","pl"].forEach(l=>{
  if(!T[l]) T[l]=T.en;
});

function detectLang(){
  const saved=localStorage.getItem("macpeek-lang");
  if(saved&&T[saved]) return saved;
  const nav=navigator.language||"en";
  if(T[nav]) return nav;
  const short=nav.split("-")[0];
  if(T[short]) return short;
  return "en";
}

function applyLang(lang){
  const strings=T[lang]||T.en;
  document.querySelectorAll("[data-i18n]").forEach(el=>{
    const key=el.getAttribute("data-i18n");
    if(strings[key]) el.innerHTML=strings[key];
  });
  document.documentElement.lang=lang;
  if(lang==="ar") document.documentElement.dir="rtl"; else document.documentElement.dir="ltr";
  localStorage.setItem("macpeek-lang",lang);
  const flag=document.getElementById("currentLangFlag");
  if(flag) flag.textContent=LANGS[lang]?.flag||"🌐";
}

function buildLangDropdown(){
  const dd=document.getElementById("langDropdown");
  if(!dd) return;
  dd.innerHTML="";
  const cur=detectLang();
  Object.keys(LANGS).forEach(code=>{
    const btn=document.createElement("button");
    btn.textContent=LANGS[code].flag+" "+LANGS[code].name;
    btn.className=code===cur?"active":"";
    btn.onclick=()=>{applyLang(code);dd.classList.remove("open");
      dd.querySelectorAll("button").forEach(b=>b.classList.remove("active"));
      btn.classList.add("active");
    };
    dd.appendChild(btn);
  });
}

window.applyLang=applyLang;
window.detectLang=detectLang;
window.buildLangDropdown=buildLangDropdown;
