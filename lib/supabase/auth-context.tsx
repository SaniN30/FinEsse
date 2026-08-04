"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import type { Session } from "@supabase/supabase-js";
import { getSupabaseClient } from "@/lib/supabase/client";
import type { Profile } from "@/lib/supabase/types";

interface AuthContextValue {
  session: Session | null;
  profile: Profile | null;
  loading: boolean;
  refreshProfile: () => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

async function fetchProfile(userId: string): Promise<Profile | null> {
  const supabase = getSupabaseClient();
  const { data } = await supabase
    .from("profiles")
    .select("id, role, parent_id, tier, display_name, education_level")
    .eq("id", userId)
    .maybeSingle();

  return (data as Profile | null) ?? null;
}

/**
 * Owns the single GoTrue session listener for the app. Later phases (auth,
 * consent) build on top of this same provider rather than instantiating
 * their own client/listener.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [sessionResolved, setSessionResolved] = useState(false);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [profileUserId, setProfileUserId] = useState<string | null>(null);

  useEffect(() => {
    const supabase = getSupabaseClient();
    let isMounted = true;

    supabase.auth.getSession().then(({ data }) => {
      if (!isMounted) return;
      setSession(data.session);
      setSessionResolved(true);
    });

    const { data: subscription } = supabase.auth.onAuthStateChange(
      (_event, nextSession) => {
        if (!isMounted) return;
        setSession(nextSession);
        setSessionResolved(true);
        if (!nextSession) {
          setProfile(null);
          setProfileUserId(null);
        }
      },
    );

    return () => {
      isMounted = false;
      subscription.subscription.unsubscribe();
    };
  }, []);

  useEffect(() => {
    const userId = session?.user.id;
    if (!userId || userId === profileUserId) {
      return;
    }

    let isMounted = true;
    fetchProfile(userId).then((nextProfile) => {
      if (!isMounted) return;
      setProfile(nextProfile);
      setProfileUserId(userId);
    });

    return () => {
      isMounted = false;
    };
  }, [session?.user.id, profileUserId]);

  const refreshProfile = useCallback(async () => {
    const supabase = getSupabaseClient();
    const { data } = await supabase.auth.getSession();
    setSession(data.session);
    setSessionResolved(true);
    const userId = data.session?.user.id;
    if (!userId) {
      setProfile(null);
      setProfileUserId(null);
      return;
    }
    const nextProfile = await fetchProfile(userId);
    setProfile(nextProfile);
    setProfileUserId(userId);
  }, []);

  const signOut = useCallback(async () => {
    const supabase = getSupabaseClient();
    await supabase.auth.signOut();
  }, []);

  const loading = !sessionResolved || (!!session && profileUserId !== session.user.id);

  const value = useMemo(
    () => ({ session, profile, loading, refreshProfile, signOut }),
    [session, profile, loading, refreshProfile, signOut],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return ctx;
}
