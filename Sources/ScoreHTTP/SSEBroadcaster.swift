import Foundation
import NIO
import NIOHTTP1

/// Manages open Server-Sent Event connections and broadcasts events to them.
///
/// Attach it to `NIOServer` via the `sseBroadcaster` parameter. The server
/// keeps each `/__score/dev` connection alive; when the process is killed
/// (e.g. by `score dev` after a rebuild) all connections drop and the browser's
/// `onerror` handler reloads the page.
public final class SSEBroadcaster: @unchecked Sendable {
    private let lock = NSLock()
    private var channels: [ObjectIdentifier: Channel] = [:]

    public init() {}

    // MARK: - Channel management

    func addChannel(_ channel: Channel) {
        lock.lock()
        channels[ObjectIdentifier(channel)] = channel
        lock.unlock()

        // Schedule periodic keepalive comments so proxies don't drop the connection.
        channel.eventLoop.scheduleRepeatedTask(
            initialDelay: .seconds(25),
            delay: .seconds(25)
        ) { [weak self] task in
            guard let self else { task.cancel(); return }
            self.lock.lock()
            let exists = self.channels[ObjectIdentifier(channel)] != nil
            self.lock.unlock()
            guard exists, channel.isActive else { task.cancel(); return }
            var buf = channel.allocator.buffer(capacity: 16)
            buf.writeString(": keepalive\n\n")
            channel.writeAndFlush(HTTPServerResponsePart.body(.byteBuffer(buf)), promise: nil)
        }

        channel.closeFuture.whenComplete { [weak self] _ in
            self?.removeChannel(channel)
        }
    }

    private func removeChannel(_ channel: Channel) {
        lock.lock()
        channels.removeValue(forKey: ObjectIdentifier(channel))
        lock.unlock()
    }

    // MARK: - Broadcasting

    /// Push a `reload` event — triggers `location.reload()` in the browser.
    public func sendReload() {
        broadcast(event: "reload", data: "")
    }

    /// Push a `css-update` event — browser hot-swaps the stylesheet without a full reload.
    public func sendCSSUpdate(href: String) {
        broadcast(event: "css-update", data: href)
    }

    private func broadcast(event: String, data: String) {
        lock.lock()
        let all = Array(channels.values)
        lock.unlock()
        for channel in all {
            var buffer = channel.allocator.buffer(capacity: 64)
            buffer.writeString("event: \(event)\ndata: \(data)\n\n")
            channel.writeAndFlush(HTTPServerResponsePart.body(.byteBuffer(buffer)), promise: nil)
        }
    }
}
