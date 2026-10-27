"""Original Night Owl icon; standard-library RGB PNGs, no external assets."""
from pathlib import Path
import json, math, struct, zlib, sys

S = 1024
NAVY = (20, 23, 43)
MINT = (130, 240, 188)
GOLD = (255, 203, 86)
CORAL = (255, 115, 102)
pixels = bytearray(NAVY * (S * S))

def ellipse(cx, cy, rx, ry, color):
    for y in range(max(0,int(cy-ry)),min(S,int(cy+ry)+1)):
        span = rx * math.sqrt(max(0,1-((y-cy)/ry)**2))
        left, right = max(0,int(cx-span)), min(S,int(cx+span)+1)
        pixels[(y*S+left)*3:(y*S+right)*3] = bytes(color) * (right-left)

def rect(x,y,w,h,color,r=0):
    for yy in range(max(0,int(y)),min(S,int(y+h))):
        inset = 0
        edge = min(yy-y,y+h-1-yy)
        if edge < r: inset = r-math.sqrt(max(0,r*r-(r-edge)**2))
        left,right = max(0,int(x+inset)),min(S,int(x+w-inset))
        pixels[(yy*S+left)*3:(yy*S+right)*3] = bytes(color) * (right-left)

def polygon(points,color):
    for y in range(max(0,int(min(p[1] for p in points))),min(S,int(max(p[1] for p in points))+1)):
        crossings=[]
        for a,b in zip(points,points[1:]+points[:1]):
            if (a[1]<=y<b[1]) or (b[1]<=y<a[1]): crossings.append(a[0]+(y-a[1])*(b[0]-a[0])/(b[1]-a[1]))
        crossings.sort()
        for a,b in zip(crossings[::2],crossings[1::2]):
            left,right=max(0,int(a)),min(S,int(b)+1)
            pixels[(y*S+left)*3:(y*S+right)*3]=bytes(color)*(right-left)

# Gold crescent and stars above a VHS with owl-like reel eyes.
ellipse(348,235,119,119,GOLD); ellipse(398,191,111,111,NAVY)
for x,y,r in [(708,180,48),(811,280,28),(590,271,19)]: polygon([(x,y-r),(x+r*.25,y-r*.25),(x+r,y),(x+r*.25,y+r*.25),(x,y+r),(x-r*.25,y+r*.25),(x-r,y),(x-r*.25,y-r*.25)],GOLD)
rect(132,365,760,507,(7,12,24),76)
rect(118,346,788,507,MINT,76); rect(137,365,750,469,(33,42,60),59)
rect(215,394,594,66,GOLD,12); rect(248,415,210,21,NAVY,4)
rect(484,415,293,21,NAVY,4)
for x in (345,679):
    ellipse(x,589,114,114,NAVY); ellipse(x,589,95,95,MINT)
    ellipse(x,589,70,70,(237,246,229)); ellipse(x,589,42,42,NAVY)
    ellipse(x-12,573,13,13,(255,255,255))
polygon([(479,592),(545,592),(512,640)],CORAL)
rect(223,730,578,55,NAVY,10)
for n in range(18): rect(246+n*30,741,9 if n%3 else 16,32,MINT,1)
rect(291,904,442,14,GOLD,7)

def png(size):
    # Four subpixel samples give a crisp antialiased result at home-screen sizes.
    rows=bytearray()
    for y in range(size):
        rows.append(0)
        for x in range(size):
            values=[0,0,0]
            for dx,dy in ((.25,.25),(.75,.25),(.25,.75),(.75,.75)):
                sx=min(S-1,int((x+dx)*S/size)); sy=min(S-1,int((y+dy)*S/size)); off=(sy*S+sx)*3
                for c in range(3): values[c]+=pixels[off+c]
            rows.extend(v//4 for v in values)
    def chunk(name,data): return struct.pack('>I',len(data))+name+data+struct.pack('>I',zlib.crc32(name+data)&0xffffffff)
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',size,size,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(rows,9))+chunk(b'IEND',b'')

root=Path(sys.argv[1] if len(sys.argv)>1 else 'build/Assets.xcassets')
asset=root/'AppIcon.appiconset'; asset.mkdir(parents=True,exist_ok=True)
entries=[]
for idiom,sizes,scales in [('iphone',[20,29,40,60],[2,3]),('ipad',[20,29,40,76],[1,2])]:
    for size in sizes:
        for scale in scales:
            name=f'icon-{int(size*scale)}.png'
            (asset/name).write_bytes(png(int(size*scale)))
            entries.append(dict(idiom=idiom,size=f'{size}x{size}',scale=f'{scale}x',filename=name))
for idiom,size,scale in [('ipad',83.5,2),('ios-marketing',1024,1)]:
    name=f'icon-{int(size*scale)}.png'; (asset/name).write_bytes(png(int(size*scale)))
    entries.append(dict(idiom=idiom,size=f'{size}x{size}',scale=f'{scale}x',filename=name))
(asset/'Contents.json').write_text(json.dumps(dict(images=entries,info=dict(version=1,author='xcode')),indent=2))
(root/'Contents.json').write_text(json.dumps(dict(info=dict(version=1,author='xcode'))))
print('Generated original RGB Night Owl icons (no alpha).')
