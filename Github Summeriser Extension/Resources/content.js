/**
 * Gitsum – content script
 * Extracts repo metadata and README from GitHub repo pages for summarisation.
 */

const GITHUB_REPO_PATH = /^\/[^/]+\/[^/]+(?:\/)?$/;

function getRepoFromPath() {
  const path = window.location.pathname.replace(/\/$/, '');
  const parts = path.split('/').filter(Boolean);
  if (parts.length >= 2 && !['orgs', 'teams', 'search', 'settings', 'explore'].includes(parts[0])) {
    return { owner: parts[0], repo: parts[1] };
  }
  return null;
}

function getTextContent(el) {
  if (!el) return '';
  return (el.textContent || '').trim();
}

function getRepoInfo() {
  const repo = getRepoFromPath();
  if (!repo) return null;

  const info = {
    url: window.location.href,
    owner: repo.owner,
    repo: repo.repo,
    name: `${repo.owner}/${repo.repo}`,
    description: '',
    readmeText: ''
  };

  // Description: meta or visible description
  const metaDesc = document.querySelector('meta[property="og:description"]');
  if (metaDesc && metaDesc.content) {
    info.description = metaDesc.content.trim();
  }
  if (!info.description) {
    const descEl = document.querySelector('[data-pjax="#repo-content-pjax-container"] p, .f4.mb-3, [itemprop="description"]');
    if (descEl) info.description = getTextContent(descEl);
  }

  // README: primary source is #readme .markdown-body
  const readmeEl = document.querySelector('#readme .markdown-body, #readme article.markdown-body, article.markdown-body.entry-content, [data-target="readme-toc"]');
  const readmeContainer = readmeEl?.closest('#readme') || readmeEl;
  const markdownEl = readmeContainer?.querySelector('.markdown-body') || readmeEl;
  if (markdownEl) {
    info.readmeText = getTextContent(markdownEl);
  }

  // If README is empty, try repo description and any visible about text
  if (!info.readmeText && info.description) {
    info.readmeText = info.description;
  }

  return info;
}

function buildProjectContent(info) {
  const parts = [
    `Repository: ${info.name}`,
    `URL: ${info.url}`,
    ''
  ];
  if (info.description) {
    parts.push('Description:', info.description, '');
  }
  if (info.readmeText) {
    parts.push('README / Project content:', '---', info.readmeText);
  }
  return parts.join('\n');
}

browser.runtime.onMessage.addListener((request, _sender, sendResponse) => {
  if (request.action === 'getProjectContent') {
    const info = getRepoInfo();
    if (!info) {
      sendResponse({ ok: false, error: 'Not a GitHub repository page' });
      return true;
    }
    const content = buildProjectContent(info);
    if (!content.replace(/\s/g, '').length) {
      sendResponse({ ok: false, error: 'No readable project content found on this page' });
      return true;
    }
    sendResponse({
      ok: true,
      url: info.url,
      name: info.name,
      content,
      description: info.description,
      hasReadme: !!info.readmeText
    });
    return true;
  }
  return false;
});
