import {writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
const root = fileURLToPath(new URL('../', import.meta.url));
const save=(p,s)=>writeFileSync(root+p,s);
const svg=s=>`<svg xmlns="http://www.w3.org/2000/svg" width="600" height="560" viewBox="0 0 600 560">${s}</svg>`;
const heart=(x,y,s,color)=>`<path transform="translate(${x} ${y}) scale(${s})" fill="${color}" d="M0 8C-12-6-26 6-17 17L0 32 17 17C26 6 12-6 0 8Z"/>`;
save('assets/woman/woman_body.svg',svg(`
<circle cx="300" cy="280" r="246" fill="#fbe2e4"/>
<circle cx="300" cy="280" r="223" fill="#fff0eb"/>
${heart(104,128,.8,'#efa0b3')}${heart(485,153,.65,'#ef9aad')}${heart(520,356,.4,'#ebafbc')}${heart(83,351,.45,'#e9adbc')}
<g fill="#ecc092"><circle cx="431" cy="79" r="5"/><circle cx="126" cy="428" r="5"/><path d="M509 226v18m-9-9h18" stroke="#dcb786" stroke-width="3" stroke-linecap="round"/></g>
<ellipse cx="296" cy="512" rx="177" ry="14" fill="#e5c5ce"/>
<path d="M159 237C130 116 173 68 254 69C344 60 371 125 346 270L319 342 171 330Z" fill="#584139"/>
<path d="M217 290L216 335 287 339 287 283" fill="#f5bf9e" stroke="#9f695d" stroke-width="4"/>
<path d="M208 318Q143 327 132 388L116 496Q126 515 160 512L355 512Q380 479 358 390Q352 335 296 321L253 350Z" fill="#fffaf3" stroke="#ae8077" stroke-width="4"/>
<path d="M208 318L253 350 231 376 190 326M296 321L253 350 275 375 314 329" fill="#f1d8c7" stroke="#ae8077" stroke-width="3" stroke-linejoin="round"/>
<path d="M164 401L155 481Q211 503 279 482" fill="none" stroke="#b8948a" stroke-width="4" stroke-linecap="round"/>
<path d="M324 371Q353 367 374 409L397 443 407 428 441 438Q437 480 409 494Q387 503 368 483L329 438" fill="#fffaf3" stroke="#ae8077" stroke-width="4" stroke-linejoin="round"/>
<path d="M395 443L405 424 439 435 435 453Z" fill="#f1d8c7" stroke="#ae8077" stroke-width="3"/>
<circle cx="254" cy="396" r="4" fill="#bc9284"/><circle cx="254" cy="441" r="4" fill="#bc9284"/>
<ellipse cx="170" cy="206" rx="17" ry="24" fill="#f7c7a9" stroke="#9f695d" stroke-width="3"/>
<ellipse cx="332" cy="206" rx="17" ry="24" fill="#f7c7a9" stroke="#9f695d" stroke-width="3"/>
<path d="M174 153Q170 115 246 110Q328 108 330 171L326 225Q322 285 254 307Q185 285 177 231Z" fill="#f9ceb0" stroke="#9f695d" stroke-width="4"/>
<path d="M171 172Q171 96 244 98Q326 89 339 174Q291 159 260 126Q224 170 171 172Z" fill="#584139"/>
<path d="M179 137Q207 95 252 98" fill="none" stroke="#79574a" stroke-width="6" stroke-linecap="round"/>
<path d="M199 205Q211 193 223 205M280 205Q292 193 304 205" fill="none" stroke="#634438" stroke-width="6" stroke-linecap="round"/>
<ellipse cx="202" cy="230" rx="19" ry="11" fill="#ed9b95" opacity=".6"/><ellipse cx="301" cy="230" rx="19" ry="11" fill="#ed9b95" opacity=".6"/>
<path d="M249 219L245 230 253 232" fill="none" stroke="#ce9179" stroke-width="3" stroke-linecap="round"/>
<path d="M232 248Q252 279 273 248Z" fill="#b95664" stroke="#a15158" stroke-width="3" stroke-linejoin="round"/>
<path d="M239 249H266" stroke="#fff7ec" stroke-width="5" stroke-linecap="round"/>
<circle cx="174" cy="236" r="5" fill="#deb369"/><circle cx="332" cy="236" r="5" fill="#deb369"/>
`));
const wrist='<path d="M58 185L57 218 94 223 101 184" fill="#f9ceb0" stroke="#9f695d" stroke-width="4" stroke-linejoin="round"/>';
const wrap=s=>`<g fill="#f9ceb0" stroke="#9f695d" stroke-width="4" stroke-linecap="round" stroke-linejoin="round">${s}</g>`;
const shapes={
heart:wrap(`<path d="M48 175Q36 155 43 131L60 105 62 60Q62 43 74 44Q86 44 85 59L85 115 104 103Q115 98 122 109L135 144Q140 174 113 190Q91 204 61 191Z"/><path d="M57 153L97 83Q105 71 115 79Q124 86 116 98L87 148"/><path d="M85 118L101 139M102 112L117 135M117 123L125 143" fill="none"/><path d="M66 173Q83 159 87 148" fill="none"/>`),
fox:wrap(`<path d="M47 173L34 68Q33 54 44 52Q55 49 58 65L70 119 88 115 115 58Q121 46 131 51Q141 57 134 71L119 128Q135 170 111 191Q86 205 59 190Z"/><path d="M68 113Q72 93 85 108L96 131Q105 151 89 158L61 145Q48 135 60 126L89 132"/><path d="M89 113Q99 100 110 116L119 142Q119 154 107 157L88 152"/>`),
peace:wrap(`<path d="M48 175L39 145Q36 133 44 126L36 43Q34 28 46 26Q58 25 60 40L73 109 87 31Q89 15 102 18Q114 20 110 36L99 119Q120 111 127 133L135 158Q131 189 105 196L63 190Z"/><path d="M94 118Q103 110 111 122L119 149Q119 163 108 165L86 147"/><path d="M49 131Q51 119 63 122L94 145Q105 155 97 166Q89 173 79 166L61 154"/>`),
ok:wrap(`<path d="M51 180Q29 148 32 125L27 73Q27 60 38 60Q49 60 51 73L58 112 61 43Q63 29 75 31Q87 33 84 47L81 112 94 55Q97 42 108 46Q119 50 115 63L102 120Q132 128 129 159Q127 190 102 198L65 192Z"/><path d="M64 130Q76 98 105 99Q137 101 140 130Q145 151 127 162Q105 174 88 160L67 146"/><path d="M91 130Q99 116 110 120Q122 125 118 137Q114 150 102 145Q93 142 91 130Z" fill="#fff0eb"/><path d="M57 156Q66 170 84 171" fill="none"/>`),
thumbs_up:wrap(`<path d="M56 191L43 167Q32 143 42 123L60 101 68 44Q70 29 81 33Q97 37 94 62L87 107 125 109Q140 110 137 127L130 173Q126 194 104 198Z"/><path d="M97 126L134 129M95 146L132 149M95 165L128 168" fill="none"/><path d="M62 117Q77 135 65 153" fill="none"/>`),
open:wrap(`<path d="M52 187L24 142 10 113Q4 99 15 95Q24 91 32 103L48 124 29 50Q26 37 37 34Q49 31 52 45L67 98 59 26Q58 11 70 11Q82 10 83 26L88 96 92 31Q93 17 105 19Q116 21 113 36L109 103 123 59Q127 46 138 51Q148 55 143 69L124 139Q125 177 105 195L64 196Z"/><path d="M53 130Q76 121 89 140M66 163Q84 152 104 163" fill="none"/>`),
point:wrap(`<path d="M50 182Q33 155 43 128L61 110 59 32Q59 16 72 16Q85 16 85 32L86 109Q99 95 110 113Q126 110 132 129L137 155Q136 186 109 197L65 194Z"/><path d="M87 110L100 145M109 115L119 142" fill="none"/><path d="M47 130Q50 119 62 126L89 148Q99 159 89 169Q82 175 70 164L59 156"/>`)
};
for(const [name,shape] of Object.entries(shapes)) {
 save(`assets/hands/${name}.svg`,svg(`<g transform="translate(349 258) scale(.85)">${wrist}${shape}</g>`));
}
save('assets/ui/target.svg',`<svg xmlns="http://www.w3.org/2000/svg" width="160" height="220" viewBox="0 0 160 220">${wrist}${shapes.heart}${heart(123,29,.48,'#e85d80')}</svg>`);
save('assets/ui/icon.svg',`<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><rect width="128" height="128" rx="32" fill="#fff0eb"/>${heart(64,27,2.1,'#e85d80')}</svg>`);
console.log('Created original woman, seven interchangeable hand poses, target and icon.');
