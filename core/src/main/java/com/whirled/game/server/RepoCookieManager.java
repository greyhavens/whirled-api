//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.jdbc.RepositoryListenerUnit;
import com.samskivert.jdbc.WriteOnlyUnit;
import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.presents.annotation.MainInvoker;

import com.whirled.game.server.persist.GameCookieRepository;

/**
 * A manager that stores cookies in a persistent repository.
 */
@Singleton
public class RepoCookieManager implements GameCookieManager
{
    // from interface GameCookieManager
    public void getCookie (final int gameId, final int userId, ResultListener<byte[]> rl)
    {
        if (userId == 0) {
            rl.requestCompleted(null);
            return;
        }

        _invoker.postUnit(new RepositoryListenerUnit<byte[]>("getCookie", rl) {
            public byte[] invokePersistResult () throws Exception {
                return _repo.getCookie(gameId, userId);
            }
        });
    }

    // from interface GameCookieManager
    public void setCookie (final int gameId, final int userId, final byte[] cookie)
    {
        if (userId == 0) {
            return; // fail to save, silently
        }

        _invoker.postUnit(new WriteOnlyUnit("setCookie(" + gameId + ", " + userId + ")") {
            public void invokePersist () throws Exception {
                _repo.setCookie(gameId, userId, cookie);
            }
        });
    }

    /** The invoker on which we do our database operations. */
    @Inject protected @MainInvoker Invoker _invoker;

    /** Our database repository, which is used in real operation. */
    @Inject protected GameCookieRepository _repo;
}
