browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.greeting === "hello")
        return Promise.resolve({ farewell: "goodbye" });
    return false;
});
