/**
 * GitSummarizer – popup script
 * Gets project content from the active tab and requests a summary from the native app (Apple Foundation Model).
 */

const HOST_APP_ID = 'TiTiBooL.GitSummarizer';

const states = {
  notGitHub: 'state-not-github',
  noContent: 'state-no-content',
  ready: 'state-ready',
  loading: 'state-loading',
  result: 'state-result',
  error: 'state-error'
};

let lastProject = null;
let conversation = [];

function showState(id) {
  Object.values(states).forEach(s => {
    const el = document.getElementById(s);
    if (el) el.hidden = s !== id;
  });
}

function getActiveTab() {
  return browser.tabs.query({ active: true, currentWindow: true }).then(tabs => tabs[0]);
}

function requestProjectContent() {
  return getActiveTab().then(tab => {
    if (!tab?.id) return Promise.reject(new Error('No active tab'));
    return browser.tabs.sendMessage(tab.id, { action: 'getProjectContent' });
  });
}

function sendNativeSummarise(content) {
  return browser.runtime.sendNativeMessage(HOST_APP_ID, {
    action: 'summarise',
    content
  });
}

function sendNativeChat(content, conversationHistory, newMessage) {
  return browser.runtime.sendNativeMessage(HOST_APP_ID, {
    action: 'chat',
    content,
    conversation: conversationHistory,
    newMessage
  });
}

function init() {
  showState(states.loading);

  requestProjectContent()
    .then(res => {
      if (!res.ok) {
        if (res.error && res.error.includes('Not a GitHub')) {
          showState(states.notGitHub);
        } else {
          showState(states.noContent);
        }
        return;
      }
      lastProject = res;
      document.getElementById('repo-name').textContent = res.name;
      showState(states.ready);
    })
    .catch(() => {
      showState(states.notGitHub);
    });
}

function runSummarise() {
  if (!lastProject?.content) {
    init();
    return;
  }
  showState(states.loading);

  sendNativeSummarise(lastProject.content)
    .then(response => {
      if (response?.error) {
        document.getElementById('error-message').textContent = response.error;
        showState(states.error);
        return;
      }
      const text = response?.summary ?? response?.echo ?? '';
      document.getElementById('summary-text').textContent = text || 'No summary returned.';
      conversation = [];
      renderChatMessages();
      showState(states.result);
    })
    .catch(err => {
      document.getElementById('error-message').textContent =
        err?.message || 'Could not reach the app. Make sure GitSummarizer app is running and Apple Intelligence is available (macOS 26+).';
      showState(states.error);
    });
}

function copySummary() {
  const el = document.getElementById('summary-text');
  if (!el?.textContent) return;
  navigator.clipboard.writeText(el.textContent).then(() => {
    const btn = document.getElementById('btn-copy');
    const orig = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => { btn.textContent = orig; }, 1500);
  });
}

function renderChatMessages() {
  const container = document.getElementById('chat-messages');
  const emptyEl = document.getElementById('chat-empty');
  if (!container) return;
  container.innerHTML = '';
  conversation.forEach(({ role, content }) => {
    const div = document.createElement('div');
    div.className = `chat-message ${role}`;
    div.setAttribute('role', 'article');
    const label = document.createElement('div');
    label.className = 'sender';
    label.textContent = role === 'user' ? 'You' : 'GitSummarizer';
    div.appendChild(label);
    const text = document.createElement('div');
    text.textContent = content;
    div.appendChild(text);
    container.appendChild(div);
  });
  container.scrollTop = container.scrollHeight;
  if (emptyEl) emptyEl.hidden = conversation.length > 0;
}

function setChatLoading(loading) {
  const el = document.getElementById('chat-loading');
  const btn = document.getElementById('btn-chat-send');
  if (el) el.hidden = !loading;
  if (btn) btn.disabled = loading;
}

function sendChatMessage() {
  const input = document.getElementById('chat-input');
  if (!input || !lastProject?.content) return;
  const text = (input.value || '').trim();
  if (!text) return;
  input.value = '';
  conversation.push({ role: 'user', content: text });
  renderChatMessages();
  setChatLoading(true);

  sendNativeChat(lastProject.content, conversation.slice(0, -1), text)
    .then(response => {
      setChatLoading(false);
      if (response?.error) {
        conversation.push({ role: 'assistant', content: `Error: ${response.error}` });
      } else {
        const reply = response?.reply ?? response?.echo ?? 'No reply.';
        conversation.push({ role: 'assistant', content: reply });
      }
      renderChatMessages();
    })
    .catch(err => {
      setChatLoading(false);
      conversation.push({
        role: 'assistant',
        content: err?.message || 'Could not reach the app. Make sure GitSummarizer is running and Apple Intelligence is available.'
      });
      renderChatMessages();
    });
}

function setupListeners() {
  document.getElementById('btn-summarise')?.addEventListener('click', runSummarise);
  document.getElementById('btn-copy')?.addEventListener('click', copySummary);
  document.getElementById('btn-again')?.addEventListener('click', () => {
    lastProject = null;
    conversation = [];
    init();
  });
  document.getElementById('btn-retry')?.addEventListener('click', () => {
    showState(states.ready);
    if (lastProject) runSummarise();
    else init();
  });
  const chatInput = document.getElementById('chat-input');
  const btnSend = document.getElementById('btn-chat-send');
  btnSend?.addEventListener('click', sendChatMessage);
  chatInput?.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendChatMessage();
    }
  });
}

setupListeners();
init();
