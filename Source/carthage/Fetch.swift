//
//  Fetch.swift
//  Carthage
//
//  Created by Justin Spahr-Summers on 2014-12-24.
//  Copyright (c) 2014 Carthage. All rights reserved.
//

import CarthageKit
import Commandant
import LlamaKit
import Foundation
import ReactiveCocoa

public struct FetchCommand: CommandType {
	public let verb = "fetch"
	public let function = "Clones or fetches a Git repository ahead of time"

	public func run(mode: CommandMode) -> Result<()> {
		return ColdSignal.fromResult(FetchOptions.evaluate(mode))
			.mergeMap { options -> ColdSignal<()> in
				let project = ProjectIdentifier.Git(options.repositoryURL)
				var eventSink = ProjectEventSink()

				return cloneOrFetchProject(project, preferHTTPS: true)
					.on(next: { event, _ in
						eventSink.put(event)
					})
					.then(.empty())
			}
			.wait()
	}
}

private struct FetchOptions: OptionsType {
	let repositoryURL: GitURL

	static func create(repositoryURL: GitURL) -> FetchOptions {
		return self(repositoryURL: repositoryURL)
	}

	static func evaluate(m: CommandMode) -> Result<FetchOptions> {
		return create
			<*> m <| Option(usage: "the Git repository that should be cloned or fetched")
	}
}
