import React from 'react';
import Head from 'next/head';
import { Container } from 'semantic-ui-react';

function Layout({ children }) {
    return (
        <Container>
            <Head>
                <link
                    rel="stylesheet"
                    href="//cdn.jsdelivr.net/npm/semantic-ui@2.4.2/dist/semantic.min.css"                    
                />
            </Head>
            {children}
        </Container>
    )
}

export default Layout