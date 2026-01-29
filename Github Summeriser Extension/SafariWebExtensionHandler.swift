//
//  SafariWebExtensionHandler.swift
//  Gitsum Extension
//
//  Handles native messages from the Safari extension and uses Apple Foundation
//  Models (Apple Intelligence) to summarise GitHub project content.
//

import SafariServices
import os.log
#if canImport(FoundationModels)
import FoundationModels
#endif

#if canImport(FoundationModels)
@available(macOS 26.0, *)
private func summarizeWithFoundationModels(_ content: String) async throws -> String {
    let model = SystemLanguageModel.default
    switch model.availability {
    case .available:
        break
    case .unavailable(.deviceNotEligible):
        throw NSError(domain: "Gitsum", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is not available on this device."])
    case .unavailable(.appleIntelligenceNotEnabled):
        throw NSError(domain: "Gitsum", code: 2, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is available but not enabled. Turn it on in System Settings."])
    case .unavailable(.modelNotReady):
        throw NSError(domain: "Gitsum", code: 3, userInfo: [NSLocalizedDescriptionKey: "The model isn’t ready. Try again in a moment."])
    case .unavailable:
        throw NSError(domain: "Gitsum", code: 4, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is unavailable."])
    }

    let session = LanguageModelSession(instructions: """
        You are a helpful assistant that summarises GitHub projects. \
        Given repository information and README/content, provide a clear, concise summary. \
        Cover: what the project does, main features, tech stack if visible, and who might use it. \
        Keep the summary to a few short paragraphs. Be accurate and avoid inventing details.
        """)
    let response = try await session.respond(to: "Summarise this GitHub project:\n\n\(content)")
    return response.content
}

@available(macOS 26.0, *)
private func chatWithFoundationModels(content: String, conversation: [[String: Any]], newMessage: String) async throws -> String {
    let model = SystemLanguageModel.default
    switch model.availability {
    case .available:
        break
    case .unavailable(.deviceNotEligible):
        throw NSError(domain: "Gitsum", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is not available on this device."])
    case .unavailable(.appleIntelligenceNotEnabled):
        throw NSError(domain: "Gitsum", code: 2, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is available but not enabled. Turn it on in System Settings."])
    case .unavailable(.modelNotReady):
        throw NSError(domain: "Gitsum", code: 3, userInfo: [NSLocalizedDescriptionKey: "The model isn’t ready. Try again in a moment."])
    case .unavailable:
        throw NSError(domain: "Gitsum", code: 4, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is unavailable."])
    }

    var conversationBlock = ""
    for entry in conversation {
        if let role = entry["role"] as? String, let text = entry["content"] as? String, !text.isEmpty {
            let label = role == "user" ? "User" : "Assistant"
            conversationBlock += "\(label): \(text)\n\n"
        }
    }
    conversationBlock += "User: \(newMessage)\n\nAssistant:"

    let session = LanguageModelSession(instructions: """
        You are a helpful assistant answering questions about a GitHub project. Use only the project content below to answer. \
        If the answer is not in the content, say so. Be concise and accurate. Do not invent details.
        """)
    let prompt = "Project content:\n\n\(content)\n\n--- Conversation ---\n\n\(conversationBlock)"
    let response = try await session.respond(to: prompt)
    return response.content
}
#endif

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        if #available(iOS 17.0, macOS 14.0, *) {
            profile = request?.userInfo?[SFExtensionProfileKey] as? UUID
        } else {
            profile = request?.userInfo?["profile"] as? UUID
        }

        let message: Any?
        if #available(iOS 15.0, macOS 11.0, *) {
            message = request?.userInfo?[SFExtensionMessageKey]
        } else {
            message = request?.userInfo?["message"]
        }

        os_log(.default, "Received message from browser.runtime.sendNativeMessage: %@ (profile: %@)", String(describing: message), profile?.uuidString ?? "none")

        var responsePayload: [String: Any] = [:]

        if let msg = message as? [String: Any], let action = msg["action"] as? String {
            if action == "summarise", let content = msg["content"] as? String, !content.isEmpty {
                if #available(macOS 26.0, *) {
                    #if canImport(FoundationModels)
                    let semaphore = DispatchSemaphore(value: 0)
                    Task {
                        do {
                            let summary = try await summarizeWithFoundationModels(content)
                            responsePayload["summary"] = summary
                        } catch {
                            responsePayload["error"] = error.localizedDescription
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                    #else
                    responsePayload["error"] = "Apple Intelligence requires macOS 26 and Xcode 26 SDK."
                    #endif
                } else {
                    responsePayload["error"] = "Apple Intelligence requires macOS 26 or later."
                }
            } else if action == "chat", let content = msg["content"] as? String, !content.isEmpty, let newMessage = msg["newMessage"] as? String, !newMessage.isEmpty {
                let conversation = msg["conversation"] as? [[String: Any]] ?? []
                if #available(macOS 26.0, *) {
                    #if canImport(FoundationModels)
                    let semaphore = DispatchSemaphore(value: 0)
                    Task {
                        do {
                            let reply = try await chatWithFoundationModels(content: content, conversation: conversation, newMessage: newMessage)
                            responsePayload["reply"] = reply
                        } catch {
                            responsePayload["error"] = error.localizedDescription
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                    #else
                    responsePayload["error"] = "Apple Intelligence requires macOS 26 and Xcode 26 SDK."
                    #endif
                } else {
                    responsePayload["error"] = "Apple Intelligence requires macOS 26 or later."
                }
            } else {
                responsePayload["error"] = "Missing or invalid request. Use action: 'summarise' with 'content', or 'chat' with 'content', 'conversation', and 'newMessage'."
            }
        } else {
            responsePayload["error"] = "Missing or invalid request. Use action: 'summarise' or 'chat'."
        }

        let response = NSExtensionItem()
        if #available(iOS 15.0, macOS 11.0, *) {
            response.userInfo = [SFExtensionMessageKey: responsePayload]
        } else {
            response.userInfo = [ "message": responsePayload ]
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
