import java.io.InputStream;
import java.security.CodeSigner;
import java.security.MessageDigest;
import java.security.cert.Certificate;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.Locale;
import java.util.Set;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

public class VerifyAab {
    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            throw new IllegalArgumentException(
                "Expected AAB path and certificate fingerprint."
            );
        }

        String expected = args[1]
            .replace(":", "")
            .toUpperCase(Locale.ROOT);

        if (!expected.matches("[A-F0-9]{64}")) {
            throw new SecurityException(
                "Invalid expected certificate fingerprint."
            );
        }

        int verified = 0;
        byte[] buffer = new byte[65536];
        Set<String> names = new HashSet<>();

        try (JarFile jar = new JarFile(args[0], true)) {
            Enumeration<JarEntry> entries = jar.entries();

            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();

                if (!names.add(entry.getName())) {
                    throw new SecurityException(
                        "Duplicate archive entry."
                    );
                }

                if (entry.isDirectory()) {
                    continue;
                }

                String name = entry.getName()
                    .toUpperCase(Locale.ROOT);

                boolean signatureMetadata =
                    name.equals("META-INF/MANIFEST.MF") ||
                    name.matches(
                        "META-INF/[^/]+\\.(SF|RSA|DSA|EC)"
                    ) ||
                    name.matches("META-INF/SIG-[^/]+");

                if (signatureMetadata) {
                    continue;
                }

                try (InputStream input =
                         jar.getInputStream(entry)) {
                    while (input.read(buffer) != -1) {
                        // Reading verifies the signed content.
                    }
                }

                CodeSigner[] signers = entry.getCodeSigners();

                if (signers == null || signers.length != 1) {
                    throw new SecurityException(
                        "Unsigned or unexpectedly signed entry: "
                        + entry.getName()
                    );
                }

                Certificate certificate = signers[0]
                    .getSignerCertPath()
                    .getCertificates()
                    .get(0);

                byte[] digest = MessageDigest
                    .getInstance("SHA-256")
                    .digest(certificate.getEncoded());

                String actual = HexFormat.of()
                    .withUpperCase()
                    .formatHex(digest);

                if (!actual.equals(expected)) {
                    throw new SecurityException(
                        "Certificate mismatch: " + entry.getName()
                    );
                }

                verified++;
            }
        }

        if (verified == 0) {
            throw new SecurityException(
                "No signed application entries found."
            );
        }

        System.out.println(
            "Verified signed AAB entries: " + verified
        );
    }
}