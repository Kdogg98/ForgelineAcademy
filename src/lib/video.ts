export function getEmbedUrl(url: string): { type: 'iframe' | 'video'; src: string } | null {
  try {
    const u = new URL(url);
    const host = u.hostname.replace('www.', '');

    if (host === 'youtube.com' || host === 'm.youtube.com' || host === 'youtube-nocookie.com') {
      const embedMatch = u.pathname.match(/^\/embed\/([^?/]+)/);
      if (embedMatch) return { type: 'iframe', src: `https://www.youtube.com/embed/${embedMatch[1]}` };
      const shortsMatch = u.pathname.match(/^\/shorts\/([^?/]+)/);
      if (shortsMatch) return { type: 'iframe', src: `https://www.youtube.com/embed/${shortsMatch[1]}` };
      const liveMatch = u.pathname.match(/^\/live\/([^?/]+)/);
      if (liveMatch) return { type: 'iframe', src: `https://www.youtube.com/embed/${liveMatch[1]}` };
      const videoId = u.searchParams.get('v');
      if (videoId) return { type: 'iframe', src: `https://www.youtube.com/embed/${videoId}` };
    }
    if (host === 'youtu.be') {
      const videoId = u.pathname.slice(1).split('?')[0];
      if (videoId) return { type: 'iframe', src: `https://www.youtube.com/embed/${videoId}` };
    }
    if (host === 'vimeo.com') {
      const videoId = u.pathname.split('/').filter(Boolean)[0];
      if (videoId) return { type: 'iframe', src: `https://player.vimeo.com/video/${videoId}` };
    }
    if (host === 'player.vimeo.com') {
      return { type: 'iframe', src: url };
    }
    if (host === 'loom.com' || host === 'www.loom.com') {
      const parts = u.pathname.split('/');
      const shareIdx = parts.indexOf('share');
      if (shareIdx >= 0 && parts[shareIdx + 1]) {
        return { type: 'iframe', src: `https://www.loom.com/embed/${parts[shareIdx + 1]}` };
      }
      const embedIdx = parts.indexOf('embed');
      if (embedIdx >= 0 && parts[embedIdx + 1]) {
        return { type: 'iframe', src: url };
      }
    }
    if (/\.(mp4|webm|ogg|mov|m4v)(\?|$)/i.test(u.pathname)) {
      return { type: 'video', src: url };
    }
    if (url.includes('module-videos')) {
      return { type: 'video', src: url };
    }
    return null;
  } catch {
    return null;
  }
}
